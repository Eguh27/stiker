use std::fs;

use image::imageops::FilterType;
use image::{DynamicImage, ImageDecoder, RgbaImage};

use crate::api::errors::EncodeError;

const STICKER_SIZE_PX: u32 = 512;
const QUALITY_STEPS: [f32; 10] = [90.0, 80.0, 70.0, 60.0, 50.0, 40.0, 30.0, 20.0, 10.0, 0.0];

/// Decodes `input_path`, fits it on a 512x512 transparent canvas, and writes
/// the highest quality step that stays below `target_size_kb` to `output_path`.
pub(crate) fn encode_sticker(
    input_path: &str,
    output_path: &str,
    target_size_kb: u32,
) -> Result<(), EncodeError> {
    let image = decode_image(input_path)?;
    let canvas = fit_on_square_canvas(image);
    let encoded = encode_under_budget(&canvas, target_size_kb)?;

    fs::write(output_path, encoded).map_err(|_| EncodeError::EncodeFailed)
}

fn decode_image(input_path: &str) -> Result<DynamicImage, EncodeError> {
    let reader = image::ImageReader::open(input_path)
        .map_err(|_| EncodeError::InputNotFound)?
        .with_guessed_format()
        .map_err(|_| EncodeError::InvalidImage)?;
    let mut decoder = reader
        .into_decoder()
        .map_err(|_| EncodeError::InvalidImage)?;
    let orientation = decoder
        .orientation()
        .map_err(|_| EncodeError::InvalidImage)?;
    let mut image = DynamicImage::from_decoder(decoder).map_err(|_| EncodeError::InvalidImage)?;
    image.apply_orientation(orientation);

    if image.width() == 0 || image.height() == 0 {
        return Err(EncodeError::InvalidImage);
    }

    Ok(image)
}

fn fit_on_square_canvas(image: DynamicImage) -> RgbaImage {
    let resized = image.resize(STICKER_SIZE_PX, STICKER_SIZE_PX, FilterType::Lanczos3);
    let rgba = resized.to_rgba8();
    let x = i64::from((STICKER_SIZE_PX - rgba.width()) / 2);
    let y = i64::from((STICKER_SIZE_PX - rgba.height()) / 2);

    let mut canvas = RgbaImage::new(STICKER_SIZE_PX, STICKER_SIZE_PX);
    image::imageops::overlay(&mut canvas, &rgba, x, y);
    canvas
}

fn encode_under_budget(canvas: &RgbaImage, target_size_kb: u32) -> Result<Vec<u8>, EncodeError> {
    let max_bytes = u64::from(target_size_kb) * 1024;
    let encoder = webp::Encoder::from_rgba(canvas.as_raw(), STICKER_SIZE_PX, STICKER_SIZE_PX);

    for quality in QUALITY_STEPS {
        let encoded = encoder
            .encode_simple(false, quality)
            .map_err(|_| EncodeError::EncodeFailed)?;

        if (encoded.len() as u64) < max_bytes {
            return Ok(encoded.to_vec());
        }
    }

    Err(EncodeError::TooLargeAfterQualityLoop)
}

#[cfg(test)]
mod tests;
