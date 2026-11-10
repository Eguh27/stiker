package com.example.sticker_studio.share

import android.content.ContentResolver
import android.net.Uri
import android.provider.OpenableColumns
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.IOException

class ShareImportException(message: String) : Exception(message)

class SharedContentCopier(
    private val contentResolver: ContentResolver,
    private val originalsDirectory: File,
) {
    suspend fun copy(uriString: String, id: String): File =
        withContext(Dispatchers.IO) {
            val uri = Uri.parse(uriString)
            if (uri.scheme != ContentResolver.SCHEME_CONTENT) {
                throw ShareImportException("Sumber file tidak didukung")
            }

            val part = File(originalsDirectory, ".$id.part")
            try {
                ensureOriginalsDirectory()
                val extension = ImageMimeTypes.extensionFor(
                    contentResolver.getType(uri),
                ) ?: throw ShareImportException("Jenis gambar tidak didukung")
                rejectOversized(uri)
                copyStream(uri, part)
                val destination = File(originalsDirectory, "$id.$extension")
                if (!part.renameTo(destination)) {
                    throw ShareImportException("Gagal menyimpan file sumber")
                }
                destination
            } catch (error: ShareImportException) {
                part.delete()
                throw error
            } catch (error: SecurityException) {
                part.delete()
                throw ShareImportException(
                    "Izin akses file dari aplikasi sumber ditolak",
                )
            } catch (error: IOException) {
                part.delete()
                throw ShareImportException(
                    "Gagal menyalin file dari aplikasi sumber",
                )
            }
        }

    private fun ensureOriginalsDirectory() {
        if (!originalsDirectory.isDirectory && !originalsDirectory.mkdirs()) {
            throw IOException("Cannot create originals directory")
        }
    }

    private fun rejectOversized(uri: Uri) {
        contentResolver.query(
            uri,
            arrayOf(OpenableColumns.SIZE),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst() && !cursor.isNull(0)) {
                if (cursor.getLong(0) > MAX_BYTES) {
                    throw ShareImportException(TOO_LARGE_MESSAGE)
                }
            }
        }
    }

    private fun copyStream(uri: Uri, part: File) {
        val input = contentResolver.openInputStream(uri)
            ?: throw ShareImportException("Gagal membaca file dari aplikasi sumber")
        input.use { source ->
            part.delete()
            part.outputStream().use { destination ->
                val buffer = ByteArray(BUFFER_SIZE)
                var total = 0L
                var read = source.read(buffer)
                while (read >= 0) {
                    total += read
                    if (total > MAX_BYTES) {
                        throw ShareImportException(TOO_LARGE_MESSAGE)
                    }
                    destination.write(buffer, 0, read)
                    read = source.read(buffer)
                }
            }
        }
    }

    private companion object {
        const val MAX_BYTES = 50L * 1024L * 1024L
        const val BUFFER_SIZE = 64 * 1024
        const val TOO_LARGE_MESSAGE = "Ukuran file terlalu besar (maks 50 MB)"
    }
}
