use std::net::{IpAddr, Ipv4Addr, Ipv6Addr};

use reqwest::Url;

use crate::api::errors::ResolveError;

#[derive(Debug, Clone, Copy, Default)]
pub(crate) struct UrlPolicy {
    pub(crate) allow_loopback: bool,
}

impl UrlPolicy {
    pub(crate) fn validate(self, raw: &str) -> Result<Url, ResolveError> {
        let url = Url::parse(raw).map_err(|_| ResolveError::UnsupportedType)?;
        if !matches!(url.scheme(), "http" | "https") {
            return Err(ResolveError::UnsupportedType);
        }
        if !url.username().is_empty() || url.password().is_some() {
            return Err(ResolveError::UnsupportedType);
        }
        let host = url.host_str().ok_or(ResolveError::UnsupportedType)?;
        if host.is_empty() || host.ends_with('.') {
            return Err(ResolveError::UnsupportedType);
        }
        if self.is_blocked_host(host) {
            return Err(ResolveError::Blocked);
        }
        if !self.allows_test_port(host) && !matches!(url.port_or_known_default(), Some(80 | 443)) {
            return Err(ResolveError::UnsupportedType);
        }
        Ok(url)
    }

    fn allows_test_port(self, host: &str) -> bool {
        if !self.allow_loopback {
            return false;
        }
        let normalized = host.trim_matches(['[', ']']);
        normalized == "localhost"
            || normalized
                .parse::<IpAddr>()
                .is_ok_and(|address| address.is_loopback())
    }

    fn is_blocked_host(self, host: &str) -> bool {
        let normalized = host.trim_matches(['[', ']']).to_ascii_lowercase();
        if normalized == "localhost" || normalized.ends_with(".localhost") {
            return !self.allow_loopback;
        }
        if normalized.ends_with(".local")
            || normalized.ends_with(".internal")
            || normalized.ends_with(".lan")
        {
            return true;
        }
        if let Ok(ip) = normalized.parse::<IpAddr>() {
            return !(self.allow_loopback && ip.is_loopback()) && is_blocked_ip(ip);
        }
        if normalized.chars().all(|c| c.is_ascii_digit() || c == '.') {
            return true;
        }
        false
    }
}

fn is_blocked_ip(ip: IpAddr) -> bool {
    match ip {
        IpAddr::V4(ip) => is_blocked_ipv4(ip),
        IpAddr::V6(ip) => is_blocked_ipv6(ip),
    }
}

fn is_blocked_ipv4(ip: Ipv4Addr) -> bool {
    let octets = ip.octets();
    ip.is_unspecified()
        || ip.is_loopback()
        || ip.is_private()
        || ip.is_link_local()
        || ip.is_multicast()
        || ip.is_broadcast()
        || octets[0] == 0
        || octets[0] >= 240
        || (octets[0] == 100 && (64..=127).contains(&octets[1]))
        || (octets[0] == 192 && octets[1] == 0 && octets[2] == 0)
        || (octets[0] == 198 && (18..=19).contains(&octets[1]))
}

fn is_blocked_ipv6(ip: Ipv6Addr) -> bool {
    ip.is_unspecified()
        || ip.is_loopback()
        || ip.is_multicast()
        || ip.is_unique_local()
        || ip.is_unicast_link_local()
        || ip.to_ipv4_mapped().is_some_and(is_blocked_ipv4)
}

pub(crate) fn has_image_extension(url: &Url) -> bool {
    let path = url.path().to_ascii_lowercase();
    [".jpg", ".jpeg", ".png", ".webp"]
        .iter()
        .any(|extension| path.ends_with(extension))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn accepts_public_https_urls() {
        let url = UrlPolicy::default()
            .validate("https://example.com/pin/123")
            .expect("public url");
        assert_eq!(url.host_str(), Some("example.com"));
    }

    #[test]
    fn rejects_non_http_schemes() {
        assert_eq!(
            UrlPolicy::default().validate("file:///etc/passwd"),
            Err(ResolveError::UnsupportedType)
        );
    }

    #[test]
    fn rejects_credentials_and_unusual_ports() {
        assert_eq!(
            UrlPolicy::default().validate("https://user:pass@example.com/a.jpg"),
            Err(ResolveError::UnsupportedType)
        );
        assert_eq!(
            UrlPolicy::default().validate("https://example.com:8443/a.jpg"),
            Err(ResolveError::UnsupportedType)
        );
    }

    #[test]
    fn rejects_local_and_private_hosts() {
        for raw in [
            "http://localhost/a.jpg",
            "http://127.0.0.1/a.jpg",
            "http://10.0.0.8/a.jpg",
            "http://192.168.1.2/a.jpg",
            "http://169.254.1.1/a.jpg",
            "http://[::1]/a.jpg",
            "http://printer.local/a.jpg",
            "http://2130706433/a.jpg",
        ] {
            assert_eq!(
                UrlPolicy::default().validate(raw),
                Err(ResolveError::Blocked),
                "{raw}"
            );
        }
    }

    #[test]
    fn allows_loopback_only_when_explicitly_enabled() {
        let policy = UrlPolicy {
            allow_loopback: true,
        };
        assert!(policy.validate("http://127.0.0.1:8080/a.jpg").is_ok());
        assert_eq!(
            policy.validate("http://10.0.0.8/a.jpg"),
            Err(ResolveError::Blocked)
        );
    }

    #[test]
    fn detects_direct_image_extensions() {
        let url = Url::parse("https://cdn.example.com/a/b/photo.JPG?x=1").unwrap();
        assert!(has_image_extension(&url));
        assert!(!has_image_extension(
            &Url::parse("https://example.com/pin/1").unwrap()
        ));
    }
}
