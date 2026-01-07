package com.example.pedometer_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * BootReceiver automatically starts the step counter service after device reboot.
 *
 * This is critical because:
 * 1. The TYPE_STEP_COUNTER sensor resets to zero on reboot
 * 2. Without this receiver, users would have to manually open the app after every reboot
 * 3. Days could go by with zero steps recorded after a reboot
 */
class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Received broadcast: ${intent.action}")

        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d(TAG, "Device boot completed - starting step counter service")

            val serviceIntent = Intent(context, StepCounterService::class.java).apply {
                action = StepCounterService.ACTION_START
            }

            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d(TAG, "Step counter service started successfully after boot")

                // Also schedule the watchdog to check service health periodically
                ServiceWatchdogReceiver.scheduleWatchdog(context)
                Log.d(TAG, "Service watchdog scheduled after boot")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start service after boot: ${e.message}", e)
            }
        }
    }
}
