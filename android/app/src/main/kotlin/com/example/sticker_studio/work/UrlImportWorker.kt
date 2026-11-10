package com.example.sticker_studio.work

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import kotlinx.coroutines.CancellationException

class UrlImportWorker(
    appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {
    override suspend fun doWork(): Result {
        return try {
            if (HeadlessImportEngine(applicationContext).run()) {
                Result.success()
            } else {
                retryOrFail()
            }
        } catch (error: CancellationException) {
            throw error
        } catch (error: Exception) {
            Log.w(TAG, "Impor URL latar belakang gagal dijalankan", error)
            retryOrFail()
        }
    }

    private fun retryOrFail(): Result =
        if (runAttemptCount < MAX_ATTEMPTS) {
            Result.retry()
        } else {
            Result.failure()
        }

    private companion object {
        const val TAG = "UrlImportWorker"
        const val MAX_ATTEMPTS = 3
    }
}
