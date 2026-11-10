package com.example.sticker_studio.data

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import com.example.sticker_studio.share.ShareSourceType
import java.io.File
import java.io.IOException

class ImportQueueWriter(private val context: Context) {
    fun enqueueLocal(
        id: String,
        localInputPath: String,
        sourceType: ShareSourceType,
    ) {
        insert(
            id = id,
            sourceUrl = null,
            localInputPath = localInputPath,
            sourceType = sourceType,
            status = STATUS_PENDING,
            errorMessage = null,
        )
    }

    fun enqueueUrl(
        id: String,
        sourceUrl: String,
        sourceType: ShareSourceType,
    ) {
        insert(
            id = id,
            sourceUrl = sourceUrl,
            localInputPath = null,
            sourceType = sourceType,
            status = STATUS_PENDING,
            errorMessage = null,
        )
    }

    fun enqueueFailed(
        sourceType: ShareSourceType,
        message: String,
        id: String = ImportIdGenerator.newId(),
    ) {
        insert(
            id = id,
            sourceUrl = null,
            localInputPath = null,
            sourceType = sourceType,
            status = STATUS_FAILED,
            errorMessage = message,
        )
    }

    private fun insert(
        id: String,
        sourceUrl: String?,
        localInputPath: String?,
        sourceType: ShareSourceType,
        status: String,
        errorMessage: String?,
    ) {
        val databaseFile = File(context.filesDir, ImportQueueSchema.DATABASE_RELATIVE_PATH)
        val parent = databaseFile.parentFile
        if (parent != null && !parent.isDirectory && !parent.mkdirs()) {
            throw IOException("Cannot create database directory")
        }

        val now = System.currentTimeMillis() / 1000
        val values = ContentValues().apply {
            put("id", id)
            put("source_url", sourceUrl)
            put("local_input_path", localInputPath)
            put("source_type", sourceType.databaseValue)
            put("status", status)
            put("progress", 0)
            put("error_message", errorMessage)
            put("auto_rmbg", 0)
            put("created_at", now)
            put("updated_at", now)
        }

        SQLiteDatabase.openDatabase(
            databaseFile.absolutePath,
            null,
            SQLiteDatabase.OPEN_READWRITE or SQLiteDatabase.CREATE_IF_NECESSARY,
        ).use { database ->
            database.rawQuery("PRAGMA busy_timeout = 5000", null).close()
            database.execSQL(ImportQueueSchema.CREATE_TABLE)
            database.insertOrThrow(ImportQueueSchema.TABLE_NAME, null, values)
        }
    }

    private companion object {
        const val STATUS_PENDING = "PENDING"
        const val STATUS_FAILED = "FAILED"
    }
}
