package com.example.olx_prototype

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Telephony
import android.telephony.SmsMessage
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.regex.Pattern

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_autofill"
    private val SMS_PERMISSION_CODE = 101
    private var methodChannel: MethodChannel? = null
    private var smsReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            android.util.Log.d("OTP_DEBUG", "🔥🔥🔥 Method call received: ${call.method}")
            when (call.method) {
                "startListening" -> {
                    android.util.Log.d("OTP_DEBUG", "🔥 Starting SMS listener...")
                    requestSmsPermission()
                    startSmsListener()
                    result.success(true)
                }
                "stopListening" -> {
                    android.util.Log.d("OTP_DEBUG", "🔥 Stopping SMS listener...")
                    stopSmsListener()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestSmsPermission() {
        android.util.Log.d("OTP_DEBUG", "🔥 Checking SMS permissions...")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECEIVE_SMS) != PackageManager.PERMISSION_GRANTED ||
                ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
                android.util.Log.d("OTP_DEBUG", "🔥 Requesting SMS permissions...")
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.RECEIVE_SMS, Manifest.permission.READ_SMS),
                    SMS_PERMISSION_CODE
                )
            } else {
                android.util.Log.d("OTP_DEBUG", "🔥 SMS permissions already granted")
            }
        }
    }

    private fun startSmsListener() {
        android.util.Log.d("OTP_DEBUG", "🔥🔥🔥 startSmsListener called")
        
        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                android.util.Log.d("OTP_DEBUG", "🔥🔥🔥 SMS Broadcast received!")
                
                if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
                    android.util.Log.d("OTP_DEBUG", "🔥 SMS_RECEIVED_ACTION matched")
                    
                    val bundle = intent.extras
                    if (bundle != null) {
                        val pdus = bundle.get("pdus") as Array<*>?
                        android.util.Log.d("OTP_DEBUG", "🔥 PDUs count: ${pdus?.size}")
                        
                        pdus?.forEach { pdu ->
                            val smsMessage = SmsMessage.createFromPdu(pdu as ByteArray)
                            val messageBody = smsMessage.messageBody
                            android.util.Log.d("OTP_DEBUG", "🔥🔥🔥 SMS MESSAGE: $messageBody")
                            
                            val code = extractOtpFromMessage(messageBody)
                            android.util.Log.d("OTP_DEBUG", "🔥🔥🔥 EXTRACTED OTP: $code")
                            
                            code?.let {
                                android.util.Log.d("OTP_DEBUG", "🔥 Sending OTP to Flutter: $it")
                                methodChannel?.invokeMethod("onSmsReceived", it)
                                android.util.Log.d("OTP_DEBUG", "🔥 OTP sent to Flutter successfully")
                            }
                        }
                    }
                }
            }
        }
        
        val intentFilter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(smsReceiver, intentFilter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(smsReceiver, intentFilter)
        }
        android.util.Log.d("OTP_DEBUG", "🔥 BroadcastReceiver registered for SMS")
    }

    private fun stopSmsListener() {
        smsReceiver?.let {
            try {
                unregisterReceiver(it)
                android.util.Log.d("OTP_DEBUG", "🔥 SMS receiver unregistered")
            } catch (e: Exception) {
                android.util.Log.e("OTP_DEBUG", "❌ Error unregistering receiver: ${e.message}")
            }
        }
        smsReceiver = null
    }

    private fun extractOtpFromMessage(message: String): String? {
        android.util.Log.d("OTP_DEBUG", "🔥 Extracting OTP from: $message")
        // Extract 4 or 6 digit OTP from message
        val pattern = Pattern.compile("\\b\\d{4,6}\\b")
        val matcher = pattern.matcher(message)
        val result = if (matcher.find()) {
            matcher.group(0)
        } else null
        android.util.Log.d("OTP_DEBUG", "🔥 Extracted OTP result: $result")
        return result
    }

    override fun onDestroy() {
        stopSmsListener()
        super.onDestroy()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERMISSION_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                android.util.Log.d("OTP_DEBUG", "🔥 SMS permission granted by user")
            } else {
                android.util.Log.d("OTP_DEBUG", "❌ SMS permission denied by user")
            }
        }
    }
}
