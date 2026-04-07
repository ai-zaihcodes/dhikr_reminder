package com.example.dhikr_reminder.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * BroadcastReceiver that listens for screen unlock events
 * and triggers the Dhikr reminder overlay.
 */
class ScreenUnlockReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "ScreenUnlockReceiver"
        private const val CHANNEL_NAME = "com.example.dhikr_reminder/screen"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_USER_PRESENT -> {
                Log.d(TAG, "Screen unlocked - User present")
                triggerDhikrReminder(context)
            }
            Intent.ACTION_SCREEN_ON -> {
                Log.d(TAG, "Screen turned on")
                // Optional: Also trigger on screen on
            }
        }
    }

    private fun triggerDhikrReminder(context: Context) {
        // Start the reminder service
        val serviceIntent = Intent(context, DhikrReminderService::class.java).apply {
            putExtra("action", "show_reminder")
        }
        
        try {
            context.startForegroundService(serviceIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting service: ${e.message}")
            // Fallback to regular service
            context.startService(serviceIntent)
        }
    }
}
