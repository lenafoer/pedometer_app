package com.example.pedometer_app

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.pedometer_app/step_service"
    private val EVENT_CHANNEL = "com.example.pedometer_app/step_events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    startStepCounterService()
                    result.success(true)
                }
                "stopService" -> {
                    stopStepCounterService()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    result.success(StepCounterService.isServiceRunning)
                }
                "isSensorAvailable" -> {
                    val sensorManager = getSystemService(SENSOR_SERVICE) as android.hardware.SensorManager
                    val sensor = sensorManager.getDefaultSensor(android.hardware.Sensor.TYPE_STEP_COUNTER)
                    result.success(sensor != null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    StepCounterService.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    StepCounterService.eventSink = null
                }
            }
        )
    }

    private fun startStepCounterService() {
        val intent = Intent(this, StepCounterService::class.java).apply {
            action = StepCounterService.ACTION_START
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }

        // Schedule the watchdog to check service health every 15 minutes
        ServiceWatchdogReceiver.scheduleWatchdog(this)
    }

    private fun stopStepCounterService() {
        val intent = Intent(this, StepCounterService::class.java).apply {
            action = StepCounterService.ACTION_STOP
        }
        startService(intent)
    }
}
