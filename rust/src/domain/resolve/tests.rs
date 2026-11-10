use std::fs;
use std::io::{Read, Write};
use std::net::TcpListener;
use std::path::Path;
use std::thread;

use super::pipeline::resolve_media_with_policy;
use super::url_policy::UrlPolicy;
use crate::api::errors::ResolveError;

struct Route {
    path: &'static str,
    status: u16,
    content_type: &'static str,
    body: String,
    extra_headers: String,
}

impl Route {
    fn new(path: &'static str, status: u16, content_type: &'static str, body: &str) -> Self {
        Self {
            path,
            status,
            content_type,
            body: body.to_string(),
            extra_headers: String::new(),
        }
    }

    fn with_header(mut self, header: &str) -> Self {
        self.extra_headers = format!("{header}\r\n");
        self
    }
}

fn serve(routes: Vec<Route>) -> (String, thread::JoinHandle<()>) {
    let listener = TcpListener::bind("127.0.0.1:0").expect("bind test server");
    let address = listener.local_addr().expect("server address");
    let handle = thread::spawn(move || {
        for stream in listener.incoming().take(routes.len()) {
            let mut stream = stream.expect("accept request");
            let mut buffer = [0_u8; 4096];
            let read = stream.read(&mut buffer).expect("read request");
            let request = String::from_utf8_lossy(&buffer[..read]);
            let path = request
                .split_whitespace()
                .nth(1)
                .expect("request path")
                .to_string();
            let route = routes
                .iter()
                .find(|route| route.path == path)
                .unwrap_or_else(|| panic!("unexpected request path {path}"));
            let response = format!(
                "HTTP/1.1 {} OK\r\nContent-Type: {}\r\nContent-Length: {}\r\n{}Connection: close\r\n\r\n{}",
                route.status,
                route.content_type,
                route.body.len(),
                route.extra_headers,
                route.body
            );
            let _ = stream.write_all(response.as_bytes());
        }
    });
    (format!("http://{address}"), handle)
}

fn manifest_dir(contents: &str) -> (tempfile::TempDir, String) {
    let dir = tempfile::tempdir().expect("temp dir");
    let path = dir.path().join("extractors_manifest.json");
    fs::write(&path, contents).expect("write manifest");
    (dir, path.to_string_lossy().into_owned())
}

fn pinterest_manifest() -> (tempfile::TempDir, String) {
    manifest_dir(
        r#"{"version":1,"extractors":[{"domain":["127.0.0.1"],"strategy":"og_image","needs_login":false}]}"#,
    )
}

fn output_path(dir: &Path) -> String {
    dir.join("downloaded.image").to_string_lossy().into_owned()
}

fn test_policy() -> UrlPolicy {
    UrlPolicy {
        allow_loopback: true,
    }
}

async fn resolve(url: &str, output: &str, manifest: &str) -> Result<(), ResolveError> {
    resolve_media_with_policy(url, output, manifest, test_policy()).await
}

#[tokio::test]
async fn downloads_direct_image_link() {
    let (base, server) = serve(vec![Route::new(
        "/photo.png",
        200,
        "image/png",
        "png-bytes",
    )]);
    let (manifest_dir, manifest) = pinterest_manifest();
    let output = output_path(manifest_dir.path());

    let result = resolve(&format!("{base}/photo.png"), &output, &manifest).await;

    server.join().expect("server finished");
    result.expect("download succeeds");
    assert_eq!(
        fs::read_to_string(output).expect("read output"),
        "png-bytes"
    );
}

#[tokio::test]
async fn follows_relative_og_image_from_html_page() {
    let html = r#"<html><head><meta property="og:image" content="/img/pin.jpg"></head></html>"#;
    let (base, server) = serve(vec![
        Route::new("/pin/1", 200, "text/html; charset=utf-8", html),
        Route::new("/img/pin.jpg", 200, "image/jpeg", "jpeg-bytes"),
    ]);
    let (manifest_dir, manifest) = pinterest_manifest();
    let output = output_path(manifest_dir.path());

    let result = resolve(&format!("{base}/pin/1"), &output, &manifest).await;

    server.join().expect("server finished");
    result.expect("og:image resolves");
    assert_eq!(
        fs::read_to_string(output).expect("read output"),
        "jpeg-bytes"
    );
}

#[tokio::test]
async fn resolves_relative_og_image_against_redirected_page() {
    let html = r#"<html><head><meta property="og:image" content="/img/pin.jpg"></head></html>"#;
    let (base, server) = serve(vec![
        Route::new("/short", 302, "text/html", "").with_header("Location: /pin/1"),
        Route::new("/pin/1", 200, "text/html; charset=utf-8", html),
        Route::new("/img/pin.jpg", 200, "image/jpeg", "jpeg-bytes"),
    ]);
    let (manifest_dir, manifest) = pinterest_manifest();
    let output = output_path(manifest_dir.path());

    let result = resolve(&format!("{base}/short"), &output, &manifest).await;

    server.join().expect("server finished");
    result.expect("og:image resolves after redirect");
    assert_eq!(
        fs::read_to_string(output).expect("read output"),
        "jpeg-bytes"
    );
}

#[tokio::test]
async fn reports_needs_login_for_manifest_rule() {
    let (base, server) = serve(vec![Route::new("/pin/1", 403, "text/html", "denied")]);
    let (manifest_dir, manifest) = manifest_dir(
        r#"{"version":1,"extractors":[{"domain":["127.0.0.1"],"strategy":"og_image","needs_login":true}]}"#,
    );
    let output = output_path(manifest_dir.path());

    let result = resolve(&format!("{base}/pin/1"), &output, &manifest).await;

    server.join().expect("server finished");
    assert_eq!(result, Err(ResolveError::NeedsLogin));
    assert!(!Path::new(&output).exists());
}

#[tokio::test]
async fn reports_needs_login_for_login_wall_page() {
    let html = r#"<html><form><input type="password"></form><a>Log in</a></html>"#;
    let (base, server) = serve(vec![Route::new("/pin/1", 200, "text/html", html)]);
    let (manifest_dir, manifest) = pinterest_manifest();
    let output = output_path(manifest_dir.path());

    let result = resolve(&format!("{base}/pin/1"), &output, &manifest).await;

    server.join().expect("server finished");
    assert_eq!(result, Err(ResolveError::NeedsLogin));
}

#[tokio::test]
async fn reports_unsupported_page_without_og_image() {
    let (base, server) = serve(vec![Route::new(
        "/page",
        200,
        "text/html",
        "<html><body>no preview</body></html>",
    )]);
    let (manifest_dir, manifest) = pinterest_manifest();
    let output = output_path(manifest_dir.path());

    let result = resolve(&format!("{base}/page"), &output, &manifest).await;

    server.join().expect("server finished");
    assert_eq!(result, Err(ResolveError::UnsupportedType));
}

#[tokio::test]
async fn blocks_redirect_to_private_network() {
    let (base, server) =
        serve(vec![Route::new("/pin/1", 302, "text/html", "")
            .with_header("Location: http://10.0.0.1/a.jpg")]);
    let (manifest_dir, manifest) = pinterest_manifest();
    let output = output_path(manifest_dir.path());

    let result = resolve(&format!("{base}/pin/1"), &output, &manifest).await;

    server.join().expect("server finished");
    assert_eq!(result, Err(ResolveError::Blocked));
}
