package com.mftracker.app

import android.content.Context
import android.database.Cursor
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "com.mftracker.app/sms"
    private val TFLITE_CHANNEL = "com.mftracker.app/tflite"
    private var tfliteHandler: TfliteHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val smsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
        
        // Set up method channel for SMS operations
        smsChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getAllSms" -> {
                    val startDate = call.argument<Long>("startDate") ?: 0L
                    val messages = getAllSmsMessages(startDate)
                    result.success(messages)
                }
                else -> result.notImplemented()
            }
        }
        
        // Register SMS receiver's method channel for real-time SMS
        SmsReceiver.methodChannel = smsChannel
        
        // Set up method channel for TFLite operations
        val tfliteChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TFLITE_CHANNEL)
        tfliteChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    tfliteHandler = TfliteHandler(applicationContext)
                    val success = tfliteHandler!!.initialize()
                    result.success(success)
                }
                "classifySMS" -> {
                    val tokens = call.argument<IntArray>("tokens")
                    if (tokens != null && tfliteHandler != null) {
                        val output = tfliteHandler!!.classifySMS(tokens)
                        if (output != null) {
                            result.success(output.toList())
                        } else {
                            result.error("INFERENCE_ERROR", "Classification failed", null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Invalid tokens or handler not initialized", null)
                    }
                }
                "extractEntities" -> {
                    val tokens = call.argument<IntArray>("tokens")
                    if (tokens != null && tfliteHandler != null) {
                        val output = tfliteHandler!!.extractEntities(tokens)
                        if (output != null) {
                            result.success(output.toList())
                        } else {
                            result.error("INFERENCE_ERROR", "NER extraction failed", null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "Invalid tokens or handler not initialized", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAllSmsMessages(startDate: Long): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        
        try {
            val uri = Uri.parse("content://sms/inbox")
            val cursor: Cursor? = contentResolver.query(
                uri,
                arrayOf("_id", "address", "body", "date"),
                "date >= ?",
                arrayOf(startDate.toString()),
                "date DESC"
            )

            cursor?.use {
                val addressIndex = it.getColumnIndex("address")
                val bodyIndex = it.getColumnIndex("body")
                val dateIndex = it.getColumnIndex("date")

                while (it.moveToNext()) {
                    val message = mapOf(
                        "address" to (it.getString(addressIndex) ?: ""),
                        "body" to (it.getString(bodyIndex) ?: ""),
                        "date" to (it.getLong(dateIndex))
                    )
                    messages.add(message)
                }
            }
        } catch (e: Exception) {
            // Return empty list if we can't read SMS (e.g., on emulator or without permission)
        }

        return messages
    }
}
