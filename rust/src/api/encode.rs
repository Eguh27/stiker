use std::path::Path;

use crate::api::errors::EncodeError;
use crate::domain::encode_pipeline::encode_sticker;

/// Encodes `input_path` into a 512x512 WebP sticker smaller than `target_size_kb`.
///
/// The image is scaled to fit, centered on a transparent canvas, and encoded
/// with the highest quality step that stays below the size budget.
pub async fn encode_whatsapp_webp(
    input_path: String,
    output_path: String,
    target_size_kb: u32,
) -> Result<String, EncodeError> {
    validate_encode_request(&input_path, &output_path, target_size_kb)?;

    let returned_output_path = output_path.clone();
    let join_result = flutter_rust_bridge::spawn_blocking_with(
        move || encode_sticker(&input_path, &output_path, target_size_kb),
        crate::frb_generated::FLUTTER_RUST_BRIDGE_HANDLER.thread_pool(),
    )
    .await;

    match join_result {
        Ok(Ok(())) => Ok(returned_output_path),
        Ok(Err(error)) => Err(error),
        Err(_) => Err(EncodeError::EncodeFailed),
    }
}

fn validate_encode_request(
    input_path: &str,
    output_path: &str,
    target_size_kb: u32,
) -> Result<(), EncodeError> {
    if !Path::new(input_path).is_file() {
        return Err(EncodeError::InputNotFound);
    }
    if output_path.trim().is_empty() || target_size_kb == 0 {
        return Err(EncodeError::EncodeFailed);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXISTING_INPUT: &str = "Cargo.toml";
    const OUTPUT: &str = "output.webp";

    #[test]
    fn rejects_missing_input_path() {
        assert_eq!(
            validate_encode_request("/missing/input.jpg", OUTPUT, 100),
            Err(EncodeError::InputNotFound)
        );
    }

    #[test]
    fn rejects_blank_output_path() {
        assert_eq!(
            validate_encode_request(EXISTING_INPUT, "  ", 100),
            Err(EncodeError::EncodeFailed)
        );
    }

    #[test]
    fn rejects_zero_target_size() {
        assert_eq!(
            validate_encode_request(EXISTING_INPUT, OUTPUT, 0),
            Err(EncodeError::EncodeFailed)
        );
    }

    #[test]
    fn accepts_valid_request() {
        assert_eq!(validate_encode_request(EXISTING_INPUT, OUTPUT, 100), Ok(()));
    }
}
