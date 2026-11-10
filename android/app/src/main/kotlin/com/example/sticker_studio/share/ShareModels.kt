package com.example.sticker_studio.share

enum class ShareSourceType(val databaseValue: String) {
    GALLERY_SHARE("GALLERY_SHARE"),
    GALLERY_PICKER("GALLERY_PICKER"),
    PINTEREST("PINTEREST"),
    GENERIC_URL("GENERIC_URL"),
    DIRECT_IMAGE_LINK("DIRECT_IMAGE_LINK"),
}

data class ShareIntentData(
    val action: String?,
    val mimeType: String?,
    val streamUris: List<String>,
    val clipUris: List<String>,
    val text: String?,
)

sealed interface SharePayload {
    data class Images(
        val uris: List<String>,
        val sourceType: ShareSourceType,
    ) : SharePayload

    data class Url(
        val url: String,
        val sourceType: ShareSourceType,
    ) : SharePayload
}

sealed interface ShareParseResult {
    data class Accepted(val payload: SharePayload) : ShareParseResult

    data class Rejected(
        val message: String,
        val sourceType: ShareSourceType,
    ) : ShareParseResult

    data object Ignored : ShareParseResult
}
