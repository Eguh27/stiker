package com.example.sticker_studio.work

import android.content.Context
import com.example.sticker_studio.data.ImportQueueSchema
import java.io.File

internal data class BackgroundImportConfig(
    val filesDir: String,
    val databasePath: String,
) {
    fun asMap(): Map<String, String> = mapOf(
        "filesDir" to filesDir,
        "databasePath" to databasePath,
    )

    companion object {
        fun from(context: Context): BackgroundImportConfig {
            val filesDir = context.filesDir
            return BackgroundImportConfig(
                filesDir = filesDir.absolutePath,
                databasePath = File(
                    filesDir,
                    ImportQueueSchema.DATABASE_RELATIVE_PATH,
                ).absolutePath,
            )
        }
    }
}
