package com.example.sticker_studio.whatsapp

import android.app.Activity
import android.content.Context
import android.util.Log
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class WhatsAppIntentHandler(
    private val context: Context,
    private val activityProvider: () -> Activity? = { null },
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "StickerStudioWA"
        const val CHANNEL_NAME = "com.example.sticker_studio/whatsapp"
        const val ACTION_ENABLE_STICKER_PACK = "com.whatsapp.intent.action.ENABLE_STICKER_PACK"
        const val EXTRA_STICKER_PACK_ID = "sticker_pack_id"
        const val EXTRA_STICKER_PACK_AUTHORITY = "sticker_pack_authority"
        const val EXTRA_STICKER_PACK_NAME = "sticker_pack_name"
        const val REQUEST_ADD_PACK = 200
        const val AUTHORITY = "com.example.sticker_studio.stickercontentprovider"
        const val PACKAGE_WHATSAPP = "com.whatsapp"
        const val PACKAGE_WHATSAPP_BUSINESS = "com.whatsapp.w4b"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isWhatsAppInstalled" -> {
                val pkg = call.argument<String>("package") ?: PACKAGE_WHATSAPP
                result.success(isPackageInstalled(pkg))
            }
            "addStickerPack" -> {
                val id = call.argument<String>("identifier")
                val name = call.argument<String>("name")
                val isBusiness = call.argument<Boolean>("isBusiness") ?: false

                if (id.isNullOrBlank() || name.isNullOrBlank()) {
                    result.error("INVALID_ARGS", "identifier and name required", null)
                    return
                }

                val targetPackage = if (isBusiness) PACKAGE_WHATSAPP_BUSINESS else PACKAGE_WHATSAPP
                if (!isPackageInstalled(targetPackage)) {
                    result.error("NOT_INSTALLED", "WhatsApp not installed: $targetPackage", null)
                    return
                }

                val intent = Intent().apply {
                    action = ACTION_ENABLE_STICKER_PACK
                    putExtra(EXTRA_STICKER_PACK_ID, id)
                    putExtra(EXTRA_STICKER_PACK_AUTHORITY, AUTHORITY)
                    putExtra(EXTRA_STICKER_PACK_NAME, name)
                    setPackage(targetPackage)
                }

                // WhatsApp mengenali pemanggil lewat startActivityForResult;
                // memakai startActivity biasa membuat permintaan diabaikan.
                val activity = activityProvider()
                if (activity == null) {
                    result.error("NO_ACTIVITY", "Activity tidak tersedia", null)
                    return
                }
                try {
                    Log.d(TAG, "ENABLE_STICKER_PACK id=$id authority=$AUTHORITY target=$targetPackage")
                    activity.startActivityForResult(intent, REQUEST_ADD_PACK)
                    result.success(true)
                } catch (e: Exception) {
                    Log.e(TAG, "Gagal membuka WhatsApp", e)
                    result.error("INTENT_FAILED", e.message, null)
                }
            }
            "getStagingDirectory" -> {
                val dir = File(context.filesDir, "wa_export_staging")
                if (!dir.exists()) {
                    dir.mkdirs()
                }
                result.success(dir.absolutePath)
            }
            else -> result.notImplemented()
        }
    }

    fun isPackageInstalled(packageName: String): Boolean {
        return try {
            context.packageManager.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }
}

