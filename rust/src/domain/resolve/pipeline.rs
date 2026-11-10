use std::fs;
use std::time::Duration;

use reqwest::header::{ACCEPT, CONTENT_TYPE, USER_AGENT};
use reqwest::redirect::Policy;
use reqwest::{Client, Response, Url};

use super::html::{extract_og_image, looks_like_login_wall};
use super::manifest::{ExtractorRule, ExtractorsManifest};
use super::url_policy::{has_image_extension, UrlPolicy};
use crate::api::errors::ResolveError;

const IMAGE_LIMIT_BYTES: usize = 25 * 1024 * 1024;
const HTML_LIMIT_BYTES: usize = 2 * 1024 * 1024;
const REQUEST_TIMEOUT: Duration = Duration::from_secs(20);
const USER_AGENT_VALUE: &str =
    "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36";

pub(crate) async fn resolve_media(
    url: &str,
    output_path: &str,
    manifest_path: &str,
) -> Result<(), ResolveError> {
    resolve_media_with_policy(url, output_path, manifest_path, UrlPolicy::default()).await
}

pub(crate) async fn resolve_media_with_policy(
    url: &str,
    output_path: &str,
    manifest_path: &str,
    policy: UrlPolicy,
) -> Result<(), ResolveError> {
    let manifest = ExtractorsManifest::load(manifest_path)?;
    let initial_url = policy.validate(url)?;
    let rule = manifest.rule_for(&initial_url);
    let client = build_client(policy)?;

    let mut response = send(&client, initial_url.clone()).await?;
    ensure_success(response.status(), rule)?;
    let final_url = response.url().clone();

    if is_image_response(&response)
        || (has_image_extension(&final_url) && !is_html_response(&response))
    {
        let bytes = read_limited(&mut response, IMAGE_LIMIT_BYTES).await?;
        return write_image(output_path, &bytes);
    }

    if !is_html_response(&response) {
        return Err(ResolveError::UnsupportedType);
    }

    let html = read_limited(&mut response, HTML_LIMIT_BYTES).await?;
    let html = String::from_utf8_lossy(&html);
    let Some(image_url) = extract_og_image(&html, &final_url, policy)? else {
        return Err(
            if rule.is_some_and(|r| r.needs_login) || looks_like_login_wall(&html) {
                ResolveError::NeedsLogin
            } else {
                ResolveError::UnsupportedType
            },
        );
    };

    let mut image_response = send(&client, image_url).await?;
    ensure_success(image_response.status(), rule)?;
    if !is_image_response(&image_response) {
        return Err(ResolveError::UnsupportedType);
    }
    let bytes = read_limited(&mut image_response, IMAGE_LIMIT_BYTES).await?;
    write_image(output_path, &bytes)
}

fn build_client(policy: UrlPolicy) -> Result<Client, ResolveError> {
    Client::builder()
        .redirect(Policy::custom(move |attempt| {
            if attempt.previous().len() >= 5 {
                return attempt.error("too many redirects");
            }
            match policy.validate(attempt.url().as_str()) {
                Ok(_) => attempt.follow(),
                Err(_) => attempt.stop(),
            }
        }))
        .timeout(REQUEST_TIMEOUT)
        .user_agent(USER_AGENT_VALUE)
        .build()
        .map_err(|_| ResolveError::Blocked)
}

async fn send(client: &Client, url: Url) -> Result<Response, ResolveError> {
    client
        .get(url)
        .header(ACCEPT, "image/*,text/html;q=0.9,*/*;q=0.1")
        .header(USER_AGENT, USER_AGENT_VALUE)
        .send()
        .await
        .map_err(|_| ResolveError::Blocked)
}

fn ensure_success(
    status: reqwest::StatusCode,
    rule: Option<&ExtractorRule>,
) -> Result<(), ResolveError> {
    if status.is_success() {
        return Ok(());
    }
    if status == reqwest::StatusCode::UNAUTHORIZED {
        return Err(ResolveError::NeedsLogin);
    }
    if status == reqwest::StatusCode::FORBIDDEN {
        return Err(if rule.is_some_and(|r| r.needs_login) {
            ResolveError::NeedsLogin
        } else {
            ResolveError::Blocked
        });
    }
    if matches!(status.as_u16(), 404 | 410) {
        return Err(ResolveError::NotFound);
    }
    Err(ResolveError::Blocked)
}

fn is_html_response(response: &Response) -> bool {
    content_type(response).starts_with("text/html")
        || content_type(response).starts_with("application/xhtml")
}

fn is_image_response(response: &Response) -> bool {
    content_type(response).starts_with("image/")
}

fn content_type(response: &Response) -> String {
    response
        .headers()
        .get(CONTENT_TYPE)
        .and_then(|value| value.to_str().ok())
        .unwrap_or_default()
        .to_ascii_lowercase()
}

async fn read_limited(response: &mut Response, limit: usize) -> Result<Vec<u8>, ResolveError> {
    if response
        .content_length()
        .is_some_and(|length| length > limit as u64)
    {
        return Err(ResolveError::UnsupportedType);
    }
    let mut body = Vec::new();
    while let Some(chunk) = response.chunk().await.map_err(|_| ResolveError::Blocked)? {
        if body.len().saturating_add(chunk.len()) > limit {
            return Err(ResolveError::UnsupportedType);
        }
        body.extend_from_slice(&chunk);
    }
    Ok(body)
}

fn write_image(output_path: &str, bytes: &[u8]) -> Result<(), ResolveError> {
    if bytes.is_empty() {
        return Err(ResolveError::NotFound);
    }
    fs::write(output_path, bytes).map_err(|_| ResolveError::NotFound)
}
