package com.example.pedometer_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class StepCounterService : Service(), SensorEventListener {
    private var sensorManager: SensorManager? = null
    private var stepCounterSensor: Sensor? = null
    private var isRunning = false

    companion object {
        private const val TAG = "StepCounterService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "step_counter_channel"
        const val ACTION_START = "START_STEP_COUNTING"
        const val ACTION_STOP = "STOP_STEP_COUNTING"

        var eventSink: EventChannel.EventSink? = null
        var isServiceRunning = false
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate")

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        stepCounterSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)

        if (stepCounterSensor == null) {
            Log.e(TAG, "Step counter sensor not available on this device")
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service onStartCommand: ${intent?.action}")

        when (intent?.action) {
            ACTION_START -> {
                if (!isRunning) {
                    startForeground(NOTIFICATION_ID, createNotification())
                    registerSensorListener()
                    isRunning = true
                    isServiceRunning = true
                }
            }
            ACTION_STOP -> {
                stopSelf()
            }
        }

        return START_STICKY
    }

    private fun registerSensorListener() {
        if (stepCounterSensor != null) {
            val registered = sensorManager?.registerListener(
                this,
                stepCounterSensor,
                SensorManager.SENSOR_DELAY_UI
            )
            Log.d(TAG, "Sensor listener registered: $registered")
        } else {
            Log.e(TAG, "Cannot register listener - sensor is null")
        }
    }

    private fun unregisterSensorListener() {
        sensorManager?.unregisterListener(this)
        Log.d(TAG, "Sensor listener unregistered")
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type == Sensor.TYPE_STEP_COUNTER) {
            val steps = event.values[0].toLong()
            Log.d(TAG, "Sensor event: steps since boot = $steps")

            // Send to Flutter via EventChannel
            eventSink?.success(mapOf(
                "steps" to steps,
                "timestamp" to System.currentTimeMillis()
            ))
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        Log.d(TAG, "Sensor accuracy changed: $accuracy")
    }

    private fun createNotification(): Notification {
        createNotificationChannel()

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Step Counter Active")
            .setContentText("Counting your steps in the background")
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Step Counter Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows that step counting is active"
                setShowBadge(false)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service onDestroy")
        unregisterSensorListener()
        isRunning = false
        isServiceRunning = false
        eventSink = null
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
