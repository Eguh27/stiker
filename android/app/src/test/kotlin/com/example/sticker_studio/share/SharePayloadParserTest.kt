package com.example.sticker_studio.share

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class SharePayloadParserTest {
    @Test
    fun `image share becomes gallery share`() {
        val result = SharePayloadParser.parse(
            data(
                action = ACTION_SEND,
                mimeType = "image/*",
                streams = listOf("content://media/1"),
            ),
        )

        val images = (result as ShareParseResult.Accepted).payload as SharePayload.Images
        assertEquals(ShareSourceType.GALLERY_SHARE, images.sourceType)
        assertEquals(listOf("content://media/1"), images.uris)
    }

    @Test
    fun `multiple image share keeps all unique uris`() {
        val result = SharePayloadParser.parse(
            data(
                action = ACTION_SEND_MULTIPLE,
                mimeType = "image/png",
                streams = listOf("content://media/1", "content://media/2"),
                clips = listOf("content://media/2", "content://media/3"),
            ),
        )

        val images = (result as ShareParseResult.Accepted).payload as SharePayload.Images
        assertEquals(
            listOf("content://media/1", "content://media/2", "content://media/3"),
            images.uris,
        )
    }

    @Test
    fun `picker action becomes gallery picker`() {
        val result = SharePayloadParser.parse(
            data(
                action = ACTION_GET_CONTENT,
                mimeType = "image/jpeg",
                clips = listOf("content://picker/1"),
            ),
        )

        val images = (result as ShareParseResult.Accepted).payload as SharePayload.Images
        assertEquals(ShareSourceType.GALLERY_PICKER, images.sourceType)
    }

    @Test
    fun `pinterest text share is classified`() {
        val result = SharePayloadParser.parse(
            data(
                action = ACTION_SEND,
                mimeType = "text/plain",
                text = "Lihat ini https://de.pinterest.com/pin/123",
            ),
        )

        val url = (result as ShareParseResult.Accepted).payload as SharePayload.Url
        assertEquals(ShareSourceType.PINTEREST, url.sourceType)
        assertEquals("https://de.pinterest.com/pin/123", url.url)
    }

    @Test
    fun `direct image link is classified`() {
        val result = SharePayloadParser.parse(
            data(
                action = ACTION_SEND,
                mimeType = "text/plain",
                text = "https://cdn.example.com/photo.JPG?size=large",
            ),
        )

        val url = (result as ShareParseResult.Accepted).payload as SharePayload.Url
        assertEquals(ShareSourceType.DIRECT_IMAGE_LINK, url.sourceType)
    }

    @Test
    fun `generic url is classified`() {
        val result = SharePayloadParser.parse(
            data(
                action = ACTION_SEND,
                mimeType = "text/plain",
                text = "https://example.com/article",
            ),
        )

        val url = (result as ShareParseResult.Accepted).payload as SharePayload.Url
        assertEquals(ShareSourceType.GENERIC_URL, url.sourceType)
    }

    @Test
    fun `too many images are rejected`() {
        val uris = (1..SharePayloadParser.MAX_IMAGES + 1).map {
            "content://media/$it"
        }

        val result = SharePayloadParser.parse(
            data(ACTION_SEND_MULTIPLE, "image/*", streams = uris),
        )

        assertTrue(result is ShareParseResult.Rejected)
        assertEquals(
            "Maksimal 20 gambar per share",
            (result as ShareParseResult.Rejected).message,
        )
    }

    @Test
    fun `image without uri is rejected`() {
        val result = SharePayloadParser.parse(
            data(ACTION_SEND, "image/png"),
        )

        assertTrue(result is ShareParseResult.Rejected)
    }

    @Test
    fun `text without url is rejected`() {
        val result = SharePayloadParser.parse(
            data(ACTION_SEND, "text/plain", text = "tanpa tautan"),
        )

        assertTrue(result is ShareParseResult.Rejected)
    }

    @Test
    fun `unsupported action is ignored`() {
        val result = SharePayloadParser.parse(
            data("android.intent.action.VIEW", "image/png"),
        )

        assertEquals(ShareParseResult.Ignored, result)
    }

    private fun data(
        action: String,
        mimeType: String?,
        streams: List<String> = emptyList(),
        clips: List<String> = emptyList(),
        text: String? = null,
    ) = ShareIntentData(action, mimeType, streams, clips, text)

    private companion object {
        const val ACTION_SEND = "android.intent.action.SEND"
        const val ACTION_SEND_MULTIPLE = "android.intent.action.SEND_MULTIPLE"
        const val ACTION_GET_CONTENT = "android.intent.action.GET_CONTENT"
    }
}
