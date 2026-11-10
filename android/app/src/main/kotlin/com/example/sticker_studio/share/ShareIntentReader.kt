package com.example.sticker_studio.share

import android.content.Intent
import android.net.Uri
import android.os.Build

object ShareIntentReader {
    fun read(intent: Intent): ShareIntentData {
        val streams = when (intent.action) {
            Intent.ACTION_SEND_MULTIPLE -> multipleStreams(intent)
            else -> listOfNotNull(singleStream(intent))
        }

        val clips = buildList {
            val clipData = intent.clipData ?: return@buildList
            for (index in 0 until clipData.itemCount) {
                clipData.getItemAt(index).uri?.let { add(it.toString()) }
            }
        }

        val textExtra = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        val clipText = intent.clipData?.let { cd ->
            (0 until cd.itemCount)
                .mapNotNull { cd.getItemAt(it).text?.toString() }
                .firstOrNull { it.isNotBlank() }
        }
        val dataText = intent.dataString
        val resolvedText = textExtra ?: clipText ?: dataText

        return ShareIntentData(
            action = intent.action,
            mimeType = intent.type,
            streamUris = streams.map(Uri::toString),
            clipUris = clips,
            text = resolvedText,
        )
    }

    @Suppress("DEPRECATION")
    private fun singleStream(intent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }

    @Suppress("DEPRECATION")
    private fun multipleStreams(intent: Intent): List<Uri> {
        val extra = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            intent.getParcelableArrayListExtra<android.os.Parcelable>(
                Intent.EXTRA_STREAM,
            )
        }
        return extra?.filterIsInstance<Uri>().orEmpty()
    }
}
