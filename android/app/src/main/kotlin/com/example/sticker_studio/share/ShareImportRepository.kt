package com.example.sticker_studio.share

import com.example.sticker_studio.data.ImportIdGenerator
import com.example.sticker_studio.data.ImportQueueWriter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class ShareImportRepository(
    private val copier: SharedContentCopier,
    private val writer: ImportQueueWriter,
    private val createId: () -> String = ImportIdGenerator::newId,
) {
    suspend fun handle(result: ShareParseResult): Boolean =
        withContext(Dispatchers.IO) {
            when (result) {
                ShareParseResult.Ignored -> false
                is ShareParseResult.Rejected -> {
                    writer.enqueueFailed(result.sourceType, result.message)
                    false
                }
                is ShareParseResult.Accepted -> importPayload(result.payload)
            }
        }

    private suspend fun importPayload(payload: SharePayload): Boolean =
        when (payload) {
            is SharePayload.Images -> {
                importImages(payload)
                false
            }
            is SharePayload.Url -> {
                writer.enqueueUrl(createId(), payload.url, payload.sourceType)
                true
            }
        }

    private suspend fun importImages(payload: SharePayload.Images) {
        for (uri in payload.uris) {
            val id = createId()
            try {
                val file = copier.copy(uri, id)
                writer.enqueueLocal(id, file.absolutePath, payload.sourceType)
            } catch (error: ShareImportException) {
                writer.enqueueFailed(
                    payload.sourceType,
                    error.message ?: "Gagal menyalin file dari aplikasi sumber",
                )
            }
        }
    }
}
