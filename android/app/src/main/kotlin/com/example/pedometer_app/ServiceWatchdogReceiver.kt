package com.example.pedometer_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.util.Log

/**
 * ServiceWatchdogReceiver checks if the step counter service is running
 * and restarts it if necessary. This provides a safety net to ensure
 * step counting never stops for more than 15 minutes.
 *
 * Why we need this:
 * - Even foreground services can be killed by the system or crash
 * - Manufacturer battery optimizations can kill services
 * - This runs every 15 minutes to check and restart if needed
 */
class ServiceWatchdogReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "ServiceWatchdog"
        private const val ACTION_CHECK = "com.example.pedometer_app.CHECK_SERVICE"
        private const val INTERVAL_MS = 15 * 60 * 1000L // 15 minutes

        /**
         * Schedule the watchdog to run periodically
         */
        fun scheduleWatchdog(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, ServiceWatchdogReceiver::class.java).apply {
                action = ACTION_CHECK
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Use inexact repeating alarm to save battery
            // This will run approximately every 15 minutes
            alarmManager.setInexactRepeating(
                AlarmManager.ELAPSED_REALTIME_WAKEUP,
                SystemClock.elapsedRealtime() + INTERVAL_MS,
                INTERVAL_MS,
                pendingIntent
            )

            Log.d(TAG, "Watchdog scheduled to run every 15 minutes")
        }

        /**
         * Cancel the watchdog (call this if user explicitly disables step counting)
         */
        fun cancelWatchdog(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, ServiceWatchdogReceiver::class.java).apply {
                action = ACTION_CHECK
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            alarmManager.cancel(pendingIntent)
            Log.d(TAG, "Watchdog cancelled")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Watchdog triggered - checking service status")

        when (intent.action) {
            ACTION_CHECK, Intent.ACTION_BOOT_COMPLETED -> {
                // Check if service is running
                if (!StepCounterService.isServiceRunning) {
                    Log.w(TAG, "Service is NOT running - restarting now")

                    val serviceIntent = Intent(context, StepCounterService::class.java).apply {
                        action = StepCounterService.ACTION_START
                    }

                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            context.startForegroundService(serviceIntent)
                        } else {
                            context.startService(serviceIntent)
                        }
                        Log.d(TAG, "Service restarted successfully")
                    } catch (e: Exception) {
                        Log.e(TAG, "Failed to restart service: ${e.message}", e)
                    }
                } else {
                    Log.d(TAG, "Service is running normally")
                }

                // Always reschedule the watchdog to ensure it keeps running
                scheduleWatchdog(context)
            }
        }
    }
}
