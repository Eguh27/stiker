use std::sync::OnceLock;

use regex::Regex;
use reqwest::Url;

use super::url_policy::UrlPolicy;
use crate::api::errors::ResolveError;

fn meta_tag_regex() -> &'static Regex {
    static REGEX: OnceLock<Regex> = OnceLock::new();
    REGEX.get_or_init(|| Regex::new(r"(?is)<meta\b[^>]*>").expect("valid meta regex"))
}

fn attribute_regex() -> &'static Regex {
    static REGEX: OnceLock<Regex> = OnceLock::new();
    REGEX.get_or_init(|| {
        Regex::new(r#"(?is)([a-z_:][a-z0-9_:.-]*)\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s>]+))"#)
            .expect("valid attribute regex")
    })
}

pub(crate) fn extract_og_image(
    html: &str,
    base: &Url,
    policy: UrlPolicy,
) -> Result<Option<Url>, ResolveError> {
    for tag in meta_tag_regex().find_iter(html) {
        let attributes = parse_attributes(tag.as_str());
        let property = attributes
            .iter()
            .find(|(name, _)| name == "property" || name == "name")
            .map(|(_, value)| value.as_str());
        if !matches!(
            property,
            Some("og:image" | "og:image:url" | "og:image:secure_url")
        ) {
            continue;
        }
        let Some(content) = attributes
            .iter()
            .find(|(name, _)| name == "content")
            .map(|(_, value)| decode_entities(value))
        else {
            continue;
        };
        let raw = base
            .join(content.trim())
            .map_err(|_| ResolveError::UnsupportedType)?;
        return Ok(Some(policy.validate(raw.as_str())?));
    }

    // Fallback untuk Pinterest: jika meta tag tidak ada / di-render dinamis
    static PINIMG_REGEX: OnceLock<Regex> = OnceLock::new();
    let pinimg = PINIMG_REGEX.get_or_init(|| {
        Regex::new(r#"https?://i\.pinimg\.com/(?:originals|736x|564x)/[^\s"'<>]+"#)
            .expect("valid pinimg regex")
    });
    if let Some(m) = pinimg.find(html) {
        if let Ok(u) = policy.validate(m.as_str()) {
            return Ok(Some(u));
        }
    }

    Ok(None)
}

pub(crate) fn looks_like_login_wall(html: &str) -> bool {
    let lower = html.to_ascii_lowercase();
    lower.contains("<form")
        && lower.contains("password")
        && (lower.contains("log in") || lower.contains("login"))
}

fn parse_attributes(tag: &str) -> Vec<(String, String)> {
    attribute_regex()
        .captures_iter(tag)
        .filter_map(|captures| {
            let name = captures.get(1)?.as_str().to_ascii_lowercase();
            let value = captures
                .get(2)
                .or_else(|| captures.get(3))
                .or_else(|| captures.get(4))?
                .as_str()
                .to_string();
            Some((name, value))
        })
        .collect()
}

fn decode_entities(value: &str) -> String {
    let mut decoded = value
        .replace("&amp;", "&")
        .replace("&quot;", "\"")
        .replace("&#39;", "'")
        .replace("&lt;", "<")
        .replace("&gt;", ">");

    while let Some(start) = decoded.find("&#") {
        let Some(end) = decoded[start..].find(';').map(|offset| start + offset) else {
            break;
        };
        let entity = &decoded[start + 2..end];
        let codepoint = if let Some(hex) = entity
            .strip_prefix('x')
            .or_else(|| entity.strip_prefix('X'))
        {
            u32::from_str_radix(hex, 16).ok()
        } else {
            entity.parse::<u32>().ok()
        };
        let Some(character) = codepoint.and_then(char::from_u32) else {
            break;
        };
        decoded.replace_range(start..=end, &character.to_string());
    }

    decoded
}

#[cfg(test)]
mod tests {
    use super::*;

    fn url(raw: &str) -> Url {
        Url::parse(raw).expect("valid url")
    }

    #[test]
    fn extracts_absolute_and_relative_og_images() {
        let base = url("https://pinterest.com/pin/1");
        let absolute = extract_og_image(
            r#"<meta property="og:image" content="https://cdn.example.com/a.jpg">"#,
            &base,
            UrlPolicy::default(),
        )
        .expect("extract")
        .expect("image");
        assert_eq!(absolute.as_str(), "https://cdn.example.com/a.jpg");

        let relative = extract_og_image(
            r#"<meta content='/img/a.jpg' property='og:image'>"#,
            &base,
            UrlPolicy::default(),
        )
        .expect("extract")
        .expect("image");
        assert_eq!(relative.as_str(), "https://pinterest.com/img/a.jpg");
    }

    #[test]
    fn decodes_html_entities_in_image_url() {
        let base = url("https://example.com/");
        let image = extract_og_image(
            r#"<meta property="og:image" content="https://cdn.example.com/a.jpg?x=1&amp;y=2&#x26;z=3">"#,
            &base,
            UrlPolicy::default(),
        )
        .expect("extract")
        .expect("image");
        assert_eq!(image.as_str(), "https://cdn.example.com/a.jpg?x=1&y=2&z=3");
    }

    #[test]
    fn rejects_private_og_image_urls() {
        let base = url("https://example.com/");
        let result = extract_og_image(
            r#"<meta property="og:image" content="http://127.0.0.1/a.jpg">"#,
            &base,
            UrlPolicy::default(),
        );
        assert_eq!(result, Err(ResolveError::Blocked));
    }

    #[test]
    fn ignores_other_meta_tags_and_detects_login_forms() {
        let base = url("https://example.com/");
        let none = extract_og_image(
            r#"<meta name="twitter:image" content="https://cdn.example.com/a.jpg">"#,
            &base,
            UrlPolicy::default(),
        )
        .expect("extract");
        assert!(none.is_none());
        assert!(looks_like_login_wall(
            "<form><input type='password'>Log in</form>"
        ));
        assert!(!looks_like_login_wall("<html>public page</html>"));
    }
}
