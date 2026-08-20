package dev.nf2.medicail

import android.os.Bundle
import androidx.core.view.WindowCompat
import com.google.firebase.appdistribution.FirebaseAppDistribution
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        super.onResume()
        FirebaseAppDistribution.getInstance().updateIfNewReleaseAvailable()
    }
}
