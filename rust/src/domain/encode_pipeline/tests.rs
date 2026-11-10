use std::fs;
use std::path::Path;

use image::{Rgba, RgbaImage};

use super::*;
use crate::api::encode::encode_whatsapp_webp;

mod fixture;

use fixture::{noise_image, output_path, sample_image, solid_image, write_png};

fn encode_fixture(image: &RgbaImage) -> (tempfile::TempDir, String, String) {
    let dir = tempfile::tempdir().expect("create temp dir");
    let input = write_png(&dir, "input.png", image);
    let output = output_path(&dir, "output.webp");

    (dir, input, output)
}

#[test]
fn encodes_512_square_webp_under_100_kb() {
    let (_dir, input, output) = encode_fixture(&sample_image(1024, 768));

    encode_sticker(&input, &output, 100).expect("encode succeeds");

    let bytes = fs::read(&output).expect("read output");
    assert!(bytes.len() < 100 * 1024, "size was {} bytes", bytes.len());
    assert_eq!(&bytes[0..4], b"RIFF");
    assert_eq!(&bytes[8..12], b"WEBP");

    let decoded = image::load_from_memory(&bytes).expect("decode output");
    assert_eq!(decoded.width(), 512);
    assert_eq!(decoded.height(), 512);
}

#[test]
fn respects_fifty_kb_budget_for_tray_icon() {
    let (_dir, input, output) = encode_fixture(&sample_image(800, 800));

    encode_sticker(&input, &output, 50).expect("encode succeeds");

    let bytes = fs::read(&output).expect("read output");
    assert!(bytes.len() < 50 * 1024, "size was {} bytes", bytes.len());
}

#[test]
fn centers_image_and_pads_with_transparent_pixels() {
    let (_dir, input, output) = encode_fixture(&solid_image(200, 100, [220, 20, 20, 255]));

    encode_sticker(&input, &output, 100).expect("encode succeeds");

    let decoded = image::open(&output).expect("open output").to_rgba8();
    assert_eq!(decoded.dimensions(), (512, 512));
    assert!(decoded.get_pixel(0, 0).0[3] < 10);
    assert!(decoded.get_pixel(511, 511).0[3] < 10);

    let center = decoded.get_pixel(256, 256).0;
    assert!(center[3] > 240);
    assert!(center[0] > 180);
    assert!(center[1] < 80);
}

#[test]
fn upscales_small_images_to_512() {
    let (_dir, input, output) = encode_fixture(&solid_image(16, 16, [20, 120, 220, 255]));

    encode_sticker(&input, &output, 100).expect("encode succeeds");

    let decoded = image::open(&output).expect("open output").to_rgba8();
    assert_eq!(decoded.dimensions(), (512, 512));
    assert!(decoded.get_pixel(256, 256).0[3] > 240);
}

#[test]
fn preserves_source_transparency() {
    let image = RgbaImage::from_fn(512, 512, |x, _| {
        if x < 256 {
            Rgba([0, 0, 0, 0])
        } else {
            Rgba([30, 160, 90, 255])
        }
    });
    let (_dir, input, output) = encode_fixture(&image);

    encode_sticker(&input, &output, 100).expect("encode succeeds");

    let decoded = image::open(&output).expect("open output").to_rgba8();
    assert!(decoded.get_pixel(64, 256).0[3] < 10);
    assert!(decoded.get_pixel(448, 256).0[3] > 240);
}

#[test]
fn returns_invalid_image_for_non_image_data() {
    let dir = tempfile::tempdir().expect("create temp dir");
    let input = dir.path().join("not-an-image.png");
    let output = output_path(&dir, "output.webp");
    fs::write(&input, b"this is not an image").expect("write invalid fixture");

    let result = encode_sticker(input.to_str().expect("utf-8 path"), &output, 100);

    assert_eq!(result, Err(EncodeError::InvalidImage));
    assert!(!Path::new(&output).exists());
}

#[test]
fn returns_too_large_when_even_lowest_quality_exceeds_budget() {
    let (_dir, input, output) = encode_fixture(&noise_image(512, 512));

    let result = encode_sticker(&input, &output, 1);

    assert_eq!(result, Err(EncodeError::TooLargeAfterQualityLoop));
    assert!(!Path::new(&output).exists());
}

#[test]
fn returns_encode_failed_when_output_cannot_be_written() {
    let dir = tempfile::tempdir().expect("create temp dir");
    let input = write_png(&dir, "input.png", &sample_image(64, 64));
    let output = dir
        .path()
        .join("missing-parent")
        .join("output.webp")
        .to_string_lossy()
        .into_owned();

    let result = encode_sticker(&input, &output, 100);

    assert_eq!(result, Err(EncodeError::EncodeFailed));
}

#[tokio::test]
async fn async_api_returns_output_path_and_writes_file() {
    let (_dir, input, output) = encode_fixture(&sample_image(640, 480));

    let result = encode_whatsapp_webp(input.clone(), output.clone(), 100).await;

    assert_eq!(result, Ok(output.clone()));
    assert!(Path::new(&output).is_file());
}

#[tokio::test]
async fn async_api_rejects_missing_input() {
    let result = encode_whatsapp_webp(
        "/missing/sticker.png".to_owned(),
        "/tmp/sticker.webp".to_owned(),
        100,
    )
    .await;

    assert_eq!(result, Err(EncodeError::InputNotFound));
}
