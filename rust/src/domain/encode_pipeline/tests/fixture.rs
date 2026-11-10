use image::{Rgba, RgbaImage};
use tempfile::TempDir;

pub(super) fn sample_image(width: u32, height: u32) -> RgbaImage {
    RgbaImage::from_fn(width, height, |x, y| {
        let red = (x % 256) as u8;
        let green = (y % 256) as u8;
        let blue = ((x / 4 + y / 4) % 256) as u8;
        Rgba([red, green, blue, 255])
    })
}

pub(super) fn noise_image(width: u32, height: u32) -> RgbaImage {
    let mut state = 0x9E37_79B9_u32;

    RgbaImage::from_fn(width, height, |_, _| {
        state = state.wrapping_mul(1_664_525).wrapping_add(1_013_904_223);
        Rgba([
            (state >> 24) as u8,
            (state >> 16) as u8,
            (state >> 8) as u8,
            255,
        ])
    })
}

pub(super) fn solid_image(width: u32, height: u32, color: [u8; 4]) -> RgbaImage {
    RgbaImage::from_pixel(width, height, Rgba(color))
}

pub(super) fn write_png(dir: &TempDir, name: &str, image: &RgbaImage) -> String {
    let path = dir.path().join(name);
    image.save(&path).expect("write fixture png");
    path.to_string_lossy().into_owned()
}

pub(super) fn output_path(dir: &TempDir, name: &str) -> String {
    dir.path().join(name).to_string_lossy().into_owned()
}
