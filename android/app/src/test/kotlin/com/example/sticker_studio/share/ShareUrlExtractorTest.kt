package com.example.sticker_studio.share

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class ShareUrlExtractorTest {
    @Test
    fun `extracts first valid url from surrounding text`() {
        val url = ShareUrlExtractor.firstValid(
            "Cek (https://example.com/a.jpg) lalu balas.",
        )

        assertEquals("https://example.com/a.jpg", url)
    }

    @Test
    fun `trims trailing punctuation`() {
        val url = ShareUrlExtractor.firstValid(
            "Lihat https://pin.it/abc123, bagus!",
        )

        assertEquals("https://pin.it/abc123", url)
    }

    @Test
    fun `skips invalid and credentialed urls`() {
        assertNull(ShareUrlExtractor.firstValid("ftp://example.com/a.jpg"))
        assertNull(ShareUrlExtractor.firstValid("https://user:pass@example.com/a.jpg"))
        assertNull(ShareUrlExtractor.firstValid("https:///missing-host"))
    }

    @Test
    fun `classification is exact for pinterest hosts`() {
        val pinterest = SourceTypeDetector.forUrl(
            ShareUrlExtractor.parse("https://www.pinterest.com/pin/1")!!,
        )
        val regional = SourceTypeDetector.forUrl(
            ShareUrlExtractor.parse("https://pinterest.co.uk/pin/1")!!,
        )
        val shortLink = SourceTypeDetector.forUrl(
            ShareUrlExtractor.parse("https://pin.it/abc123")!!,
        )
        val lookalike = SourceTypeDetector.forUrl(
            ShareUrlExtractor.parse("https://notpinterest.com/pin/1")!!,
        )
        val lookalikeSubdomain = SourceTypeDetector.forUrl(
            ShareUrlExtractor.parse("https://pinterest.com.evil.example/pin/1")!!,
        )

        assertEquals(ShareSourceType.PINTEREST, pinterest)
        assertEquals(ShareSourceType.PINTEREST, regional)
        assertEquals(ShareSourceType.PINTEREST, shortLink)
        assertEquals(ShareSourceType.GENERIC_URL, lookalike)
        assertEquals(ShareSourceType.GENERIC_URL, lookalikeSubdomain)
    }

    @Test
    fun `image extension must be at path end`() {
        val image = SourceTypeDetector.forUrl(
            ShareUrlExtractor.parse("https://cdn.example.com/a/b/c.WEBP?x=1")!!,
        )
        val page = SourceTypeDetector.forUrl(
            ShareUrlExtractor.parse("https://example.com/a.jpg/page")!!,
        )

        assertEquals(ShareSourceType.DIRECT_IMAGE_LINK, image)
        assertEquals(ShareSourceType.GENERIC_URL, page)
    }

    @Test
    fun `mime types map to safe extensions`() {
        assertEquals("jpg", ImageMimeTypes.extensionFor("image/jpeg"))
        assertEquals("png", ImageMimeTypes.extensionFor(" image/png; charset=binary"))
        assertEquals("img", ImageMimeTypes.extensionFor("image/heic"))
        assertNull(ImageMimeTypes.extensionFor("text/plain"))
        assertNull(ImageMimeTypes.extensionFor(null))
    }
}
