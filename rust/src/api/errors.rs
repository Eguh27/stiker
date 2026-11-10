/// Errors returned by the WhatsApp WebP encoder and the border generator.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum EncodeError {
    InputNotFound,
    InvalidImage,
    EncodeFailed,
    TooLargeAfterQualityLoop,
}

/// Errors returned by background-removal inference.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum InferenceError {
    ModelNotFound,
    InferenceFailed,
    Oom,
}

/// Errors returned when resolving media from an external URL.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ResolveError {
    NeedsLogin,
    Blocked,
    NotFound,
    UnsupportedType,
}
