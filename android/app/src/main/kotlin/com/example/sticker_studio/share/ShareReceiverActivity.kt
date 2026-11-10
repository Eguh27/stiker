package com.example.sticker_studio.share

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import com.example.sticker_studio.MainActivity
import com.example.sticker_studio.data.ImportQueueSchema
import com.example.sticker_studio.data.ImportQueueWriter
import com.example.sticker_studio.work.UrlImportScheduler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

class ShareReceiverActivity : Activity() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val shareIntent = intent
        if (shareIntent == null) {
            finish()
            return
        }

        scope.launch {
            try {
                val parseResult = SharePayloadParser.parse(
                    ShareIntentReader.read(shareIntent),
                )
                val hasUrl = createRepository().handle(parseResult)
                if (hasUrl) {
                    UrlImportScheduler.schedule(applicationContext)
                }

                withContext(NonCancellable + Dispatchers.Main) {
                    val toastMessage = when (parseResult) {
                        is ShareParseResult.Accepted -> {
                            if (hasUrl) "Link ditambahkan ke antrean stiker" else "Foto ditambahkan ke stiker"
                        }
                        is ShareParseResult.Rejected -> parseResult.message
                        ShareParseResult.Ignored -> "Format konten tidak didukung"
                    }
                    Toast.makeText(applicationContext, toastMessage, Toast.LENGTH_SHORT).show()

                    if (parseResult is ShareParseResult.Accepted) {
                        val mainIntent = Intent(applicationContext, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        }
                        startActivity(mainIntent)
                    }
                }
            } catch (error: Exception) {
                Log.w(TAG, "Gagal memproses share", error)
                withContext(NonCancellable + Dispatchers.Main) {
                    Toast.makeText(
                        applicationContext,
                        "Gagal menambahkan stiker: ${error.localizedMessage ?: "Terjadi kesalahan"}",
                        Toast.LENGTH_SHORT,
                    ).show()
                }
            } finally {
                withContext(NonCancellable + Dispatchers.Main) {
                    finish()
                }
            }
        }
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    private fun createRepository(): ShareImportRepository {
        val appContext = applicationContext
        val copier = SharedContentCopier(
            contentResolver = appContext.contentResolver,
            originalsDirectory = File(
                appContext.filesDir,
                ImportQueueSchema.ORIGINALS_RELATIVE_PATH,
            ),
        )
        return ShareImportRepository(copier, ImportQueueWriter(appContext))
    }

    private companion object {
        const val TAG = "ShareReceiver"
    }
}
