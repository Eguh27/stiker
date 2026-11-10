package com.example.sticker_studio.share

object ImageMimeTypes {
    private val extensionByMimeType = mapOf(
        "image/jpeg" to "jpg",
        "image/png" to "png",
        "image/webp" to "webp",
        "image/gif" to "gif",
        "image/bmp" to "bmp",
    )

    fun extensionFor(mimeType: String?): String? {
        val normalized = mimeType
            ?.substringBefore(';')
            ?.trim()
            ?.lowercase()
            ?: return null
        extensionByMimeType[normalized]?.let { return it }
        return if (normalized.startsWith("image/")) "img" else null
    }
}
