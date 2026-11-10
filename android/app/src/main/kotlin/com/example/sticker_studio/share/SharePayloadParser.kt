package com.example.sticker_studio.share

object SharePayloadParser {
    const val MAX_IMAGES = 20

    private const val ACTION_SEND = "android.intent.action.SEND"
    private const val ACTION_SEND_MULTIPLE = "android.intent.action.SEND_MULTIPLE"
    private const val ACTION_PICK = "android.intent.action.PICK"
    private const val ACTION_GET_CONTENT = "android.intent.action.GET_CONTENT"

    fun parse(data: ShareIntentData): ShareParseResult {
        if (data.action !in supportedActions) {
            return ShareParseResult.Ignored
        }

        val mimeType = data.mimeType?.lowercase()
        val uris = (data.streamUris + data.clipUris)
            .filter(String::isNotBlank)
            .distinct()
        val isPickerAction =
            data.action == ACTION_PICK || data.action == ACTION_GET_CONTENT
        val sourceType = SourceTypeDetector.forImage(isPickerAction)

        if (mimeType?.startsWith("image/") == true ||
            (mimeType != "text/plain" && uris.isNotEmpty())
        ) {
            return parseImages(uris, sourceType)
        }

        val url = data.text?.let(ShareUrlExtractor::firstValid)
        if (url != null) {
            val uri = ShareUrlExtractor.parse(url) ?: return ShareParseResult.Ignored
            return ShareParseResult.Accepted(
                SharePayload.Url(url, SourceTypeDetector.forUrl(uri)),
            )
        }

        return if (mimeType == "text/plain") {
            ShareParseResult.Rejected(
                "Tautan tidak ditemukan pada teks",
                ShareSourceType.GENERIC_URL,
            )
        } else {
            ShareParseResult.Ignored
        }
    }

    private fun parseImages(
        uris: List<String>,
        sourceType: ShareSourceType,
    ): ShareParseResult {
        if (uris.isEmpty()) {
            return ShareParseResult.Rejected(
                "Tidak ada gambar yang dibagikan",
                sourceType,
            )
        }
        if (uris.size > MAX_IMAGES) {
            return ShareParseResult.Rejected(
                "Maksimal $MAX_IMAGES gambar per share",
                sourceType,
            )
        }
        return ShareParseResult.Accepted(
            SharePayload.Images(uris, sourceType),
        )
    }

    private val supportedActions =
        setOf(ACTION_SEND, ACTION_SEND_MULTIPLE, ACTION_PICK, ACTION_GET_CONTENT)
}
