package dev.nf2.medicail

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import com.google.firebase.appdistribution.FirebaseAppDistribution
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private var screenshotEventSink: EventChannel.EventSink? = null
    private var screenCaptureCallback: Any? = null
    private var isListening = false

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "dev.nf2.medicail/screenshot_detection",
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    screenshotEventSink = events
                    isListening = true
                    registerScreenCaptureCallbackIfNeeded()
                }

                override fun onCancel(arguments: Any?) {
                    isListening = false
                    unregisterScreenCaptureCallbackIfNeeded()
                    screenshotEventSink = null
                }
            },
        )
    }

    override fun onStart() {
        super.onStart()
        if (isListening) {
            registerScreenCaptureCallbackIfNeeded()
        }
    }

    override fun onStop() {
        unregisterScreenCaptureCallbackIfNeeded()
        super.onStop()
    }

    override fun onResume() {
        super.onResume()
        FirebaseAppDistribution.getInstance().updateIfNewReleaseAvailable()
    }

    private fun registerScreenCaptureCallbackIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return
        if (screenCaptureCallback != null) return

        val callback = android.app.Activity.ScreenCaptureCallback {
            screenshotEventSink?.success(null)
        }
        screenCaptureCallback = callback
        registerScreenCaptureCallback(mainExecutor, callback)
    }

    private fun unregisterScreenCaptureCallbackIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) return
        val callback = screenCaptureCallback as? android.app.Activity.ScreenCaptureCallback ?: return
        unregisterScreenCaptureCallback(callback)
        screenCaptureCallback = null
    }
}
