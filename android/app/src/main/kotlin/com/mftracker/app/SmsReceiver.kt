package com.mftracker.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * BroadcastReceiver to listen for incoming SMS messages.
 * Automatically captures new SMS and sends them to Flutter for ML processing.
 */
class SmsReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "SmsReceiver"
        var methodChannel: MethodChannel? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            return
        }

        try {
            val smsMessages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            for (smsMessage in smsMessages) {
                val sender = smsMessage.displayOriginatingAddress ?: "Unknown"
                val messageBody = smsMessage.messageBody ?: ""
                val timestamp = smsMessage.timestampMillis

                Log.d(TAG, "New SMS from $sender: ${messageBody.take(50)}...")

                // Send SMS data to Flutter
                val smsData = mapOf(
                    "address" to sender,
                    "body" to messageBody,
                    "date" to timestamp
                )

                // Use handler to call on main thread
                android.os.Handler(android.os.Looper.getMainLooper()).post {
                    methodChannel?.invokeMethod("onSmsReceived", smsData)
                    Log.d(TAG, "SMS data sent to Flutter")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing SMS: ${e.message}", e)
        }
    }
}
