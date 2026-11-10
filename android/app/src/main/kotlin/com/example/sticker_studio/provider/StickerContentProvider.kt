package com.example.sticker_studio.provider

import android.content.ContentProvider
import android.content.ContentValues
import android.content.UriMatcher
import android.content.res.AssetFileDescriptor
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import org.json.JSONObject
import java.io.File

class StickerContentProvider : ContentProvider() {

    companion object {
        const val AUTHORITY = "com.example.sticker_studio.stickercontentprovider"
        private const val METADATA = 1
        private const val METADATA_PACK = 2
        private const val STICKERS = 3
        private const val STICKERS_ASSET = 4

        private val uriMatcher = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(AUTHORITY, "metadata", METADATA)
            addURI(AUTHORITY, "metadata/*", METADATA_PACK)
            addURI(AUTHORITY, "stickers/*", STICKERS)
            addURI(AUTHORITY, "stickers_asset/*/*", STICKERS_ASSET)
        }

        private val METADATA_COLUMNS = arrayOf(
            "sticker_pack_identifier", "sticker_pack_name", "sticker_pack_publisher",
            "sticker_pack_icon", "android_play_store_link", "ios_app_store_link",
            "publisher_email", "publisher_website", "privacy_policy_website",
            "license_agreement_website", "image_data_version", "avoid_cache",
            "animated_sticker_pack"
        )

        private val STICKER_COLUMNS = arrayOf(
            "sticker_file_name", "sticker_pack_identifier", "sticker_emojis"
        )
    }

    override fun onCreate(): Boolean = true

    override fun query(
        uri: Uri,
        projection: Array<String>?,
        selection: String?,
        selectionArgs: Array<String>?,
        sortOrder: String?
    ): Cursor? {
        val context = context ?: return null
        val stagingDir = File(context.filesDir, "wa_export_staging")

        return when (uriMatcher.match(uri)) {
            METADATA, METADATA_PACK -> {
                val packId = if (uriMatcher.match(uri) == METADATA_PACK) uri.lastPathSegment else null
                getMetadataCursor(stagingDir, packId)
            }
            STICKERS -> {
                val packId = uri.lastPathSegment ?: return null
                getStickersCursor(stagingDir, packId)
            }
            else -> null
        }
    }

    private fun getMetadataCursor(stagingDir: File, filterPackId: String?): Cursor {
        val cursor = MatrixCursor(METADATA_COLUMNS)
        val packDirs = stagingDir.listFiles { f -> f.isDirectory } ?: emptyArray()

        for (dir in packDirs) {
            val metaFile = File(dir, "metadata.json")
            if (!metaFile.exists()) continue

            try {
                val json = JSONObject(metaFile.readText())
                val packs = json.optJSONArray("sticker_packs") ?: continue
                for (i in 0 until packs.length()) {
                    val p = packs.getJSONObject(i)
                    val id = p.optString("identifier")
                    if (filterPackId != null && filterPackId != id) continue

                    cursor.addRow(arrayOf(
                        id,
                        p.optString("name"),
                        p.optString("publisher"),
                        p.optString("tray_image_file", "tray.webp"),
                        json.optString("android_play_store_link", ""),
                        json.optString("ios_app_store_link", ""),
                        json.optString("publisher_email", ""),
                        json.optString("publisher_website", ""),
                        json.optString("privacy_policy_website", ""),
                        json.optString("license_agreement_website", ""),
                        p.optString("image_data_version", "1"),
                        if (p.optBoolean("avoid_cache", false)) 1 else 0,
                        if (p.optBoolean("animated_sticker_pack", false)) 1 else 0
                    ))
                }
            } catch (_: Exception) {}
        }
        return cursor
    }

    private fun getStickersCursor(stagingDir: File, packId: String): Cursor {
        val cursor = MatrixCursor(STICKER_COLUMNS)
        val metaFile = File(stagingDir, "$packId/metadata.json")
        if (!metaFile.exists()) return cursor

        try {
            val json = JSONObject(metaFile.readText())
            val packs = json.optJSONArray("sticker_packs") ?: return cursor
            for (i in 0 until packs.length()) {
                val p = packs.getJSONObject(i)
                if (p.optString("identifier") == packId) {
                    val stickers = p.optJSONArray("stickers") ?: continue
                    for (s in 0 until stickers.length()) {
                        val st = stickers.getJSONObject(s)
                        cursor.addRow(arrayOf(
                            st.optString("image_file"),
                            packId,
                            st.optJSONArray("emojis")?.toString() ?: "[\"😀\"]"
                        ))
                    }
                }
            }
        } catch (_: Exception) {}
        return cursor
    }

    override fun openAssetFile(uri: Uri, mode: String): AssetFileDescriptor? {
        val context = context ?: return null
        if (uriMatcher.match(uri) != STICKERS_ASSET) return null

        val segments = uri.pathSegments
        if (segments.size < 3) return null
        val packId = segments[1]
        val fileName = segments[2]

        val file = File(File(context.filesDir, "wa_export_staging"), "$packId/$fileName")
        if (!file.exists()) return null

        val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
        return AssetFileDescriptor(pfd, 0, AssetFileDescriptor.UNKNOWN_LENGTH)
    }

    override fun getType(uri: Uri): String? = when (uriMatcher.match(uri)) {
        METADATA, METADATA_PACK -> "vnd.android.cursor.dir/vnd.$AUTHORITY.metadata"
        STICKERS -> "vnd.android.cursor.dir/vnd.$AUTHORITY.stickers"
        STICKERS_ASSET -> "image/webp"
        else -> null
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? = throw UnsupportedOperationException()
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<String>?): Int = throw UnsupportedOperationException()
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<String>?): Int = throw UnsupportedOperationException()
}

