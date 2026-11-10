use std::fs;

use reqwest::Url;
use serde::Deserialize;

use crate::api::errors::ResolveError;

#[derive(Debug, Deserialize)]
struct ManifestFile {
    version: u32,
    extractors: Vec<RuleFile>,
}

#[derive(Debug, Deserialize)]
struct RuleFile {
    domain: Vec<String>,
    strategy: String,
    needs_login: bool,
}

#[derive(Debug)]
pub(crate) struct ExtractorRule {
    pub(crate) domains: Vec<String>,
    pub(crate) needs_login: bool,
}

#[derive(Debug)]
pub(crate) struct ExtractorsManifest {
    rules: Vec<ExtractorRule>,
}

impl ExtractorsManifest {
    pub(crate) fn load(path: &str) -> Result<Self, ResolveError> {
        let contents = fs::read_to_string(path).map_err(|_| ResolveError::NotFound)?;
        let file: ManifestFile =
            serde_json::from_str(&contents).map_err(|_| ResolveError::UnsupportedType)?;
        if file.version != 1 || file.extractors.is_empty() {
            return Err(ResolveError::UnsupportedType);
        }

        let mut rules = Vec::with_capacity(file.extractors.len());
        for rule in file.extractors {
            if rule.strategy != "og_image" || rule.domain.is_empty() {
                return Err(ResolveError::UnsupportedType);
            }
            let domains = rule
                .domain
                .iter()
                .map(|domain| normalize_domain(domain))
                .collect::<Result<Vec<_>, _>>()?;
            rules.push(ExtractorRule {
                domains,
                needs_login: rule.needs_login,
            });
        }

        Ok(Self { rules })
    }

    pub(crate) fn rule_for(&self, url: &Url) -> Option<&ExtractorRule> {
        let host = url.host_str()?.to_ascii_lowercase();
        self.rules.iter().find(|rule| rule.matches(&host))
    }
}

impl ExtractorRule {
    fn matches(&self, host: &str) -> bool {
        self.domains
            .iter()
            .any(|domain| host == domain || host.ends_with(&format!(".{domain}")))
    }
}

fn normalize_domain(value: &str) -> Result<String, ResolveError> {
    let domain = value.trim().to_ascii_lowercase();
    let valid = !domain.is_empty()
        && !domain.contains('/')
        && !domain.contains(':')
        && domain.split('.').all(|label| {
            !label.is_empty() && label.chars().all(|c| c.is_ascii_alphanumeric() || c == '-')
        });
    if valid {
        Ok(domain)
    } else {
        Err(ResolveError::UnsupportedType)
    }
}

#[cfg(test)]
mod tests {
    use std::io::Write;

    use super::*;

    fn manifest_file(contents: &str) -> (tempfile::TempDir, String) {
        let dir = tempfile::tempdir().expect("temp dir");
        let path = dir.path().join("extractors_manifest.json");
        let mut file = fs::File::create(&path).expect("create manifest");
        file.write_all(contents.as_bytes()).expect("write manifest");
        (dir, path.to_string_lossy().into_owned())
    }

    #[test]
    fn finds_pinterest_rule_for_subdomains() {
        let (_dir, path) = manifest_file(
            r#"{"version":1,"extractors":[{"domain":["pinterest.com","pin.it"],"strategy":"og_image","needs_login":false}]}"#,
        );
        let manifest = ExtractorsManifest::load(&path).expect("valid manifest");
        let url = Url::parse("https://de.pinterest.com/pin/1").unwrap();
        let rule = manifest.rule_for(&url).expect("rule");
        assert!(!rule.needs_login);
    }

    #[test]
    fn rejects_invalid_version_and_strategy() {
        for contents in [
            r#"{"version":2,"extractors":[{"domain":["a.com"],"strategy":"og_image","needs_login":false}]}"#,
            r#"{"version":1,"extractors":[{"domain":["a.com"],"strategy":"xpath","needs_login":false}]}"#,
            r#"{"version":1,"extractors":[{"domain":["bad/domain"],"strategy":"og_image","needs_login":false}]}"#,
        ] {
            let (_dir, path) = manifest_file(contents);
            assert!(ExtractorsManifest::load(&path).is_err());
        }
    }

    #[test]
    fn matches_exact_host_and_rejects_prefix_tricks() {
        let (_dir, path) = manifest_file(
            r#"{"version":1,"extractors":[{"domain":["example.org"],"strategy":"og_image","needs_login":true}]}"#,
        );
        let manifest = ExtractorsManifest::load(&path).expect("valid manifest");
        assert!(manifest
            .rule_for(&Url::parse("https://example.org/a").unwrap())
            .is_some());
        assert!(manifest
            .rule_for(&Url::parse("https://notexample.org/a").unwrap())
            .is_none());
    }
}
