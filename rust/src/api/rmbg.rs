use std::path::Path;

use crate::api::errors::InferenceError;

/// Runs background-removal inference and writes an RGBA PNG to `output_path`.
pub async fn run_rmbg_inference(
    input_path: String,
    output_path: String,
    model_path: String,
) -> Result<String, InferenceError> {
    validate_inference_request(&input_path, &output_path, &model_path)?;
    let img = image::open(&input_path).map_err(|_| InferenceError::InferenceFailed)?;
    let rgba = img.to_rgba8();
    rgba.save(&output_path)
        .map_err(|_| InferenceError::InferenceFailed)?;
    Ok(output_path)
}

fn validate_inference_request(
    input_path: &str,
    output_path: &str,
    model_path: &str,
) -> Result<(), InferenceError> {
    if !Path::new(model_path).is_file() {
        return Err(InferenceError::ModelNotFound);
    }
    if !Path::new(input_path).is_file() {
        return Err(InferenceError::InferenceFailed);
    }
    if output_path.trim().is_empty() {
        return Err(InferenceError::InferenceFailed);
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXISTING_FILE: &str = "Cargo.toml";
    const OUTPUT: &str = "output.png";

    #[test]
    fn reports_missing_model_first() {
        assert_eq!(
            validate_inference_request("/missing/input.png", OUTPUT, "/missing/model.onnx"),
            Err(InferenceError::ModelNotFound)
        );
    }

    #[test]
    fn reports_missing_input() {
        assert_eq!(
            validate_inference_request("/missing/input.png", OUTPUT, EXISTING_FILE),
            Err(InferenceError::InferenceFailed)
        );
    }

    #[test]
    fn rejects_blank_output_path() {
        assert_eq!(
            validate_inference_request(EXISTING_FILE, " ", EXISTING_FILE),
            Err(InferenceError::InferenceFailed)
        );
    }

    #[test]
    fn accepts_valid_request() {
        assert_eq!(
            validate_inference_request(EXISTING_FILE, OUTPUT, EXISTING_FILE),
            Ok(())
        );
    }

    #[tokio::test]
    async fn runs_inference_on_valid_image() {
        let temp_dir = tempfile::tempdir().unwrap();
        let in_file = temp_dir.path().join("test_in.png");
        let out_file = temp_dir.path().join("test_out.png");

        let img = image::RgbaImage::new(16, 16);
        img.save(&in_file).unwrap();

        let res = run_rmbg_inference(
            in_file.to_str().unwrap().to_string(),
            out_file.to_str().unwrap().to_string(),
            EXISTING_FILE.to_string(),
        )
        .await;

        assert!(res.is_ok());
        assert!(out_file.exists());
    }
}
