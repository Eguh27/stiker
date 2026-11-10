package com.example.sticker_studio.data

import java.security.SecureRandom

object ImportIdGenerator {
    private val random = SecureRandom()
    private val hexDigits = "0123456789abcdef".toCharArray()

    fun newId(): String {
        val bytes = ByteArray(16)
        random.nextBytes(bytes)
        val result = CharArray(bytes.size * 2)
        bytes.forEachIndexed { index, byte ->
            val value = byte.toInt() and 0xFF
            result[index * 2] = hexDigits[value ushr 4]
            result[index * 2 + 1] = hexDigits[value and 0x0F]
        }
        return String(result)
    }
}
