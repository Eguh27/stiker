package com.example.sticker_studio.work

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout

internal class HeadlessImportEngine(private val context: Context) {
    suspend fun run(): Boolean = withContext(Dispatchers.Main.immediate) {
        val config = BackgroundImportConfig.from(context)
        val completion = CompletableDeferred<Boolean>()
        val engine = FlutterEngine(context)
        val channel = MethodChannel(
            engine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        )

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_GET_CONFIG -> result.success(config.asMap())
                METHOD_FINISHED -> {
                    result.success(null)
                    val success = call.argument<String>(ARG_RESULT) == RESULT_SUCCESS
                    completion.complete(success)
                }
                else -> result.notImplemented()
            }
        }

        try {
            val loader = FlutterInjector.instance().flutterLoader()
            if (!loader.initialized()) {
                loader.startInitialization(context)
                loader.ensureInitializationComplete(context, null)
            }
            val bundlePath = loader.findAppBundlePath()
            val entrypoint = DartExecutor.DartEntrypoint(
                bundlePath,
                DART_LIBRARY,
                DART_FUNCTION,
            )
            engine.dartExecutor.executeDartEntrypoint(entrypoint)
            withTimeout(TIMEOUT_MILLIS) { completion.await() }
        } catch (error: TimeoutCancellationException) {
            false
        } catch (error: Exception) {
            android.util.Log.e("HeadlessImport", "Error running headless import engine", error)
            false
        } finally {
            channel.setMethodCallHandler(null)
            engine.destroy()
        }
    }

    private companion object {
        const val CHANNEL_NAME =
            "com.example.sticker_studio/background_import"
        const val DART_LIBRARY =
            "package:sticker_studio/background_import.dart"
        const val DART_FUNCTION = "backgroundImportMain"
        const val METHOD_GET_CONFIG = "getConfig"
        const val METHOD_FINISHED = "finished"
        const val ARG_RESULT = "result"
        const val RESULT_SUCCESS = "success"
        const val TIMEOUT_MILLIS = 5 * 60 * 1000L
    }
}
