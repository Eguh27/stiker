package com.example.sticker_studio.whatsapp

import org.junit.Assert.assertEquals
import org.junit.Test

class WhatsAppIntentHandlerTest {

    @Test
    fun constantsMatchWhatsAppSpec() {
        assertEquals("com.whatsapp.intent.action.ENABLE_STICKER_PACK", WhatsAppIntentHandler.ACTION_ENABLE_STICKER_PACK)
        assertEquals("com.example.sticker_studio.stickercontentprovider", WhatsAppIntentHandler.AUTHORITY)
        assertEquals("EXTRA_STICKER_PACK_ID", WhatsAppIntentHandler.EXTRA_STICKER_PACK_ID)
        assertEquals("EXTRA_STICKER_PACK_AUTHORITY", WhatsAppIntentHandler.EXTRA_STICKER_PACK_AUTHORITY)
        assertEquals("EXTRA_STICKER_PACK_NAME", WhatsAppIntentHandler.EXTRA_STICKER_PACK_NAME)
        assertEquals("com.whatsapp", WhatsAppIntentHandler.PACKAGE_WHATSAPP)
        assertEquals("com.whatsapp.w4b", WhatsAppIntentHandler.PACKAGE_WHATSAPP_BUSINESS)
    }
}
