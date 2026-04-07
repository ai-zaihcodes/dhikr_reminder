package com.example.dhikr_reminder.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.core.app.NotificationCompat
import com.example.dhikr_reminder.MainActivity
import com.example.dhikr_reminder.R
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

/**
 * Foreground service that handles showing the Dhikr reminder overlay
 * when the screen is unlocked.
 */
class DhikrReminderService : Service() {
    companion object {
        private const val TAG = "DhikrReminderService"
        private const val NOTIFICATION_CHANNEL_ID = "dhikr_reminder_channel"
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_NAME = "com.example.dhikr_reminder/reminder"
    }

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var methodChannel: MethodChannel? = null
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service started with action: ${intent?.getStringExtra("action")}")
        
        // Start as foreground service
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)

        when (intent?.getStringExtra("action")) {
            "show_reminder" -> {
                showDhikrOverlay()
            }
            "hide_reminder" -> {
                removeOverlay()
            }
            "stop_service" -> {
                stopSelf()
            }
        }

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Dhikr Reminder",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Background service for Dhikr reminders"
                setShowBadge(false)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setContentTitle("Dhikr Reminder")
            .setContentText("Monitoring screen unlock events")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun showDhikrOverlay() {
        // Check if overlay permission is granted
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!android.provider.Settings.canDrawOverlays(this)) {
                Log.w(TAG, "Overlay permission not granted")
                // Launch app to request permission
                val intent = Intent(this, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    putExtra("request_overlay_permission", true)
                }
                startActivity(intent)
                return
            }
        }

        serviceScope.launch {
            try {
                // Fetch quote from Flutter via MethodChannel
                // For now, show a default overlay
                withContext(Dispatchers.Main) {
                    createOverlayView()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error showing overlay: ${e.message}")
            }
        }
    }

    private fun createOverlayView() {
        if (overlayView != null) {
            removeOverlay()
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            } else {
                WindowManager.LayoutParams.TYPE_PHONE
            },
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.TRANSLUCENT
        )

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.overlay_dhikr, null)

        // Setup close button
        overlayView?.findViewById<Button>(R.id.closeButton)?.setOnClickListener {
            removeOverlay()
        }

        // Add to window
        try {
            windowManager?.addView(overlayView, params)
            Log.d(TAG, "Overlay shown successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error adding overlay: ${e.message}")
        }
    }

    private fun removeOverlay() {
        overlayView?.let {
            try {
                windowManager?.removeView(it)
                Log.d(TAG, "Overlay removed")
            } catch (e: Exception) {
                Log.e(TAG, "Error removing overlay: ${e.message}")
            }
            overlayView = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        removeOverlay()
        serviceScope.cancel()
        Log.d(TAG, "Service destroyed")
    }
}
