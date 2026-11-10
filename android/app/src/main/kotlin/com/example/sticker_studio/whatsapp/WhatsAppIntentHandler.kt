package com.example.sticker_studio.whatsapp

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class WhatsAppIntentHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.example.sticker_studio/whatsapp"
        const val ACTION_ENABLE_STICKER_PACK = "com.whatsapp.intent.action.ENABLE_STICKER_PACK"
        const val EXTRA_STICKER_PACK_ID = "EXTRA_STICKER_PACK_ID"
        const val EXTRA_STICKER_PACK_AUTHORITY = "EXTRA_STICKER_PACK_AUTHORITY"
        const val EXTRA_STICKER_PACK_NAME = "EXTRA_STICKER_PACK_NAME"
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
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }

                try {
                    context.startActivity(intent)
                    result.success(true)
                } catch (e: Exception) {
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

