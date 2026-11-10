use std::time::Duration;

use criterion::{criterion_group, criterion_main, Criterion};
use image::{Rgba, RgbaImage};
use rust_lib_sticker_studio::api::encode::encode_whatsapp_webp;
use tempfile::TempDir;
use tokio::runtime::Runtime;

fn sample_image(width: u32, height: u32) -> RgbaImage {
    RgbaImage::from_fn(width, height, |x, y| {
        let red = (x % 256) as u8;
        let green = (y % 256) as u8;
        let blue = ((x / 4 + y / 4) % 256) as u8;
        Rgba([red, green, blue, 255])
    })
}

fn fixture() -> (TempDir, String, String) {
    let dir = TempDir::new().expect("create bench temp dir");
    let input = dir.path().join("bench_input.png");
    let output = dir.path().join("bench_output.webp");
    sample_image(1024, 768)
        .save(&input)
        .expect("write bench fixture");

    (
        dir,
        input.to_string_lossy().into_owned(),
        output.to_string_lossy().into_owned(),
    )
}

fn encode_benchmark(c: &mut Criterion) {
    let (_dir, input, output) = fixture();
    let runtime = Runtime::new().expect("create tokio runtime");

    c.bench_function("encode_whatsapp_webp_1024x768_to_512", |b| {
        b.iter(|| {
            runtime
                .block_on(encode_whatsapp_webp(input.clone(), output.clone(), 100))
                .expect("encode succeeds");
        });
    });
}

criterion_group! {
    name = benches;
    config = Criterion::default()
        .sample_size(30)
        .warm_up_time(Duration::from_secs(1))
        .measurement_time(Duration::from_secs(5));
    targets = encode_benchmark
}
criterion_main!(benches);
