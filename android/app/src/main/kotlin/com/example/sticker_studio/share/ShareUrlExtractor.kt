package com.example.sticker_studio.share

import java.net.URI

object ShareUrlExtractor {
    private val urlPattern = Regex("""https?://[^\s<>"']+""", RegexOption.IGNORE_CASE)

    private val trailingPunctuation =
        charArrayOf('.', ',', ';', ':', '!', '?', ')', ']', '}', '>', '"', '\'')

    fun firstValid(text: String): String? {
        for (match in urlPattern.findAll(text)) {
            val candidate = match.value.trimEnd(*trailingPunctuation)
            if (parse(candidate) != null) {
                return candidate
            }
        }
        return null
    }

    fun parse(raw: String): URI? {
        val uri = runCatching { URI(raw) }.getOrNull() ?: return null
        if (uri.scheme?.lowercase() !in setOf("http", "https")) {
            return null
        }
        if (uri.host.isNullOrBlank() || uri.userInfo != null) {
            return null
        }
        return uri
    }
}
