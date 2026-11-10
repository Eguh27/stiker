use crate::api::errors::EncodeError;
use image::{Rgba, RgbaImage};
use std::fs;

pub(crate) fn apply_border(
    input_path: &str,
    output_path: &str,
    width_px: i32,
    feather_pct: i32,
    color_rgba: &str,
    preview: bool,
) -> Result<(), EncodeError> {
    let img = image::open(input_path).map_err(|_| EncodeError::InvalidImage)?;
    let img = if preview && (img.width() > 256 || img.height() > 256) {
        img.thumbnail(256, 256)
    } else {
        img
    };

    let mut rgba = img.to_rgba8();
    if width_px > 0 {
        rgba = draw_border(&rgba, width_px, feather_pct, color_rgba);
    }

    save_image(&rgba, output_path)
}

fn parse_color(hex: &str) -> [u8; 4] {
    let clean = hex.strip_prefix('#').unwrap_or(hex);
    let r = u8::from_str_radix(&clean[0..2], 16).unwrap_or(255);
    let g = u8::from_str_radix(&clean[2..4], 16).unwrap_or(255);
    let b = u8::from_str_radix(&clean[4..6], 16).unwrap_or(255);
    let a = if clean.len() >= 8 {
        u8::from_str_radix(&clean[6..8], 16).unwrap_or(255)
    } else {
        255
    };
    [r, g, b, a]
}

fn draw_border(src: &RgbaImage, width: i32, feather: i32, color_hex: &str) -> RgbaImage {
    let (w, h) = src.dimensions();
    let border_color = parse_color(color_hex);
    let max_dist = width as f32;
    let feather_dist = (max_dist * (feather as f32 / 100.0)).max(1.0);
    let solid_dist = (max_dist - feather_dist).max(0.0);

    let mut dist = vec![vec![9999.0f32; w as usize]; h as usize];
    for y in 0..h {
        for x in 0..w {
            if src.get_pixel(x, y)[3] > 32 {
                dist[y as usize][x as usize] = 0.0;
            }
        }
    }

    // Forward pass
    for y in 0..h as usize {
        for x in 0..w as usize {
            let mut d = dist[y][x];
            if x > 0 {
                d = d.min(dist[y][x - 1] + 1.0);
            }
            if y > 0 {
                d = d.min(dist[y - 1][x] + 1.0);
            }
            if x > 0 && y > 0 {
                d = d.min(dist[y - 1][x - 1] + 1.414);
            }
            if x + 1 < w as usize && y > 0 {
                d = d.min(dist[y - 1][x + 1] + 1.414);
            }
            dist[y][x] = d;
        }
    }

    // Backward pass
    for y in (0..h as usize).rev() {
        for x in (0..w as usize).rev() {
            let mut d = dist[y][x];
            if x + 1 < w as usize {
                d = d.min(dist[y][x + 1] + 1.0);
            }
            if y + 1 < h as usize {
                d = d.min(dist[y + 1][x] + 1.0);
            }
            if x + 1 < w as usize && y + 1 < h as usize {
                d = d.min(dist[y + 1][x + 1] + 1.414);
            }
            if x > 0 && y + 1 < h as usize {
                d = d.min(dist[y + 1][x - 1] + 1.414);
            }
            dist[y][x] = d;
        }
    }

    let mut out = RgbaImage::new(w, h);
    for y in 0..h {
        for x in 0..w {
            let d = dist[y as usize][x as usize];
            let orig = src.get_pixel(x, y);

            if d <= max_dist {
                let alpha_factor = if d <= solid_dist {
                    1.0
                } else {
                    ((max_dist - d) / feather_dist).clamp(0.0, 1.0)
                };
                let b_a = (border_color[3] as f32 * alpha_factor) as u8;

                // Composite original over border
                let orig_a = orig[3] as f32 / 255.0;
                let bord_a = (b_a as f32 / 255.0) * (1.0 - orig_a);
                let out_a = (orig_a + bord_a).min(1.0);

                if out_a > 0.0 {
                    let r =
                        ((orig[0] as f32 * orig_a + border_color[0] as f32 * bord_a) / out_a) as u8;
                    let g =
                        ((orig[1] as f32 * orig_a + border_color[1] as f32 * bord_a) / out_a) as u8;
                    let b =
                        ((orig[2] as f32 * orig_a + border_color[2] as f32 * bord_a) / out_a) as u8;
                    out.put_pixel(x, y, Rgba([r, g, b, (out_a * 255.0) as u8]));
                }
            } else {
                out.put_pixel(x, y, *orig);
            }
        }
    }
    out
}

fn save_image(img: &RgbaImage, output_path: &str) -> Result<(), EncodeError> {
    if output_path.ends_with(".webp") {
        let (w, h) = img.dimensions();
        let enc = webp::Encoder::from_rgba(img.as_raw(), w, h);
        let webp_data = enc.encode(90.0);
        fs::write(output_path, &*webp_data).map_err(|_| EncodeError::EncodeFailed)?;
    } else {
        img.save(output_path)
            .map_err(|_| EncodeError::EncodeFailed)?;
    }
    Ok(())
}
