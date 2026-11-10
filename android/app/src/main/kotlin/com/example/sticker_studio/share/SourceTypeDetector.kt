package com.example.sticker_studio.share

import java.net.URI

object SourceTypeDetector {
    private val directImageExtensions =
        listOf(".jpg", ".jpeg", ".png", ".webp")

    private val pinterestHost =
        Regex("""(^|\.)(pinterest\.[a-z]{2,4}(\.[a-z]{2})?|pin\.it)$""")

    fun forImage(isPickerAction: Boolean): ShareSourceType =
        if (isPickerAction) {
            ShareSourceType.GALLERY_PICKER
        } else {
            ShareSourceType.GALLERY_SHARE
        }

    fun forUrl(uri: URI): ShareSourceType {
        val host = uri.host?.lowercase().orEmpty()
        if (pinterestHost.containsMatchIn(host)) {
            return ShareSourceType.PINTEREST
        }

        val path = uri.path?.lowercase().orEmpty()
        return if (directImageExtensions.any(path::endsWith)) {
            ShareSourceType.DIRECT_IMAGE_LINK
        } else {
            ShareSourceType.GENERIC_URL
        }
    }
}
