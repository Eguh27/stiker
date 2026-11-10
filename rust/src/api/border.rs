use std::path::Path;

use crate::api::errors::EncodeError;

const MAX_WIDTH_PX: i32 = 100;
const MIN_PERCENT: i32 = 0;
const MAX_PERCENT: i32 = 100;
const HEX_LENGTHS: [usize; 2] = [6, 8];

/// Draws a sticker border around `input_path` and returns `output_path`.
///
/// `preview` renders at most 256 px; the final render keeps the source size.
pub async fn generate_sticker_border(
    input_path: String,
    output_path: String,
    width_px: i32,
    feather_pct: i32,
    color_rgba: String,
    preview: bool,
) -> Result<String, EncodeError> {
    validate_border_request(
        &input_path,
        &output_path,
        width_px,
        feather_pct,
        &color_rgba,
    )?;

    crate::domain::border_pipeline::apply_border(
        &input_path,
        &output_path,
        width_px,
        feather_pct,
        &color_rgba,
        preview,
    )?;

    Ok(output_path)
}

fn validate_border_request(
    input_path: &str,
    output_path: &str,
    width_px: i32,
    feather_pct: i32,
    color_rgba: &str,
) -> Result<(), EncodeError> {
    if !(MIN_PERCENT..=MAX_WIDTH_PX).contains(&width_px) {
        return Err(EncodeError::EncodeFailed);
    }
    if !(MIN_PERCENT..=MAX_PERCENT).contains(&feather_pct) {
        return Err(EncodeError::EncodeFailed);
    }
    if !is_valid_hex_color(color_rgba) {
        return Err(EncodeError::EncodeFailed);
    }
    if !Path::new(input_path).is_file() {
        return Err(EncodeError::InputNotFound);
    }
    if output_path.trim().is_empty() {
        return Err(EncodeError::EncodeFailed);
    }
    Ok(())
}

fn is_valid_hex_color(color_rgba: &str) -> bool {
    let Some(hex) = color_rgba.strip_prefix('#') else {
        return false;
    };
    HEX_LENGTHS.contains(&hex.len()) && hex.bytes().all(|byte| byte.is_ascii_hexdigit())
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXISTING_INPUT: &str = "Cargo.toml";
    const OUTPUT: &str = "output.webp";

    fn validate(width_px: i32, feather_pct: i32, color_rgba: &str) -> Result<(), EncodeError> {
        validate_border_request(EXISTING_INPUT, OUTPUT, width_px, feather_pct, color_rgba)
    }

    #[test]
    fn accepts_valid_request() {
        assert_eq!(validate(12, 50, "#FFFFFF"), Ok(()));
        assert_eq!(validate(0, 0, "#11223344"), Ok(()));
    }

    #[test]
    fn rejects_invalid_numeric_ranges() {
        for (width_px, feather_pct) in [(-1, 50), (101, 50), (12, -1), (12, 101)] {
            assert_eq!(
                validate(width_px, feather_pct, "#FFFFFF"),
                Err(EncodeError::EncodeFailed)
            );
        }
    }

    #[test]
    fn rejects_malformed_colors() {
        for color in ["FFFFFF", "#FFF", "#GGGGGG", "#1122334"] {
            assert_eq!(validate(12, 50, color), Err(EncodeError::EncodeFailed));
        }
    }

    #[test]
    fn rejects_missing_input_path() {
        assert_eq!(
            validate_border_request("/missing/input.png", OUTPUT, 12, 50, "#FFFFFF"),
            Err(EncodeError::InputNotFound)
        );
    }

    #[tokio::test]
    async fn generates_border_successfully() {
        let temp_dir = tempfile::tempdir().unwrap();
        let in_file = temp_dir.path().join("test_in.png");
        let out_file = temp_dir.path().join("test_out.png");

        let mut img = image::RgbaImage::new(32, 32);
        for y in 8..24 {
            for x in 8..24 {
                img.put_pixel(x, y, image::Rgba([255, 0, 0, 255]));
            }
        }
        img.save(&in_file).unwrap();

        let res = generate_sticker_border(
            in_file.to_str().unwrap().to_string(),
            out_file.to_str().unwrap().to_string(),
            4,
            50,
            "#FFFFFF".to_string(),
            false,
        )
        .await;

        assert!(res.is_ok());
        assert!(out_file.exists());
    }
}
