use std::path::Path;

use crate::api::errors::ResolveError;
use crate::domain::resolve::resolve_media;

/// Downloads the image behind `url` according to `extractors_manifest_path`.
///
/// Supports direct image links and falls back to `og:image` where configured.
pub async fn resolve_external_media(
    url: String,
    output_path: String,
    extractors_manifest_path: String,
) -> Result<String, ResolveError> {
    validate_resolve_request(&url, &output_path, &extractors_manifest_path)?;
    resolve_media(&url, &output_path, &extractors_manifest_path).await?;
    Ok(output_path)
}

fn validate_resolve_request(
    url: &str,
    output_path: &str,
    extractors_manifest_path: &str,
) -> Result<(), ResolveError> {
    if !(url.starts_with("https://") || url.starts_with("http://")) {
        return Err(ResolveError::UnsupportedType);
    }
    if output_path.trim().is_empty() {
        return Err(ResolveError::NotFound);
    }
    if !Path::new(extractors_manifest_path).is_file() {
        return Err(ResolveError::NotFound);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXISTING_MANIFEST: &str = "Cargo.toml";
    const OUTPUT: &str = "output.webp";
    const URL: &str = "https://example.com/image.jpg";

    #[test]
    fn rejects_non_http_urls() {
        assert_eq!(
            validate_resolve_request("ftp://example.com/a.jpg", OUTPUT, EXISTING_MANIFEST),
            Err(ResolveError::UnsupportedType)
        );
    }

    #[test]
    fn rejects_blank_output_path() {
        assert_eq!(
            validate_resolve_request(URL, " ", EXISTING_MANIFEST),
            Err(ResolveError::NotFound)
        );
    }

    #[test]
    fn rejects_missing_manifest() {
        assert_eq!(
            validate_resolve_request(URL, OUTPUT, "/missing/extractors.json"),
            Err(ResolveError::NotFound)
        );
    }

    #[test]
    fn accepts_valid_request() {
        assert_eq!(
            validate_resolve_request(URL, OUTPUT, EXISTING_MANIFEST),
            Ok(())
        );
    }
}
