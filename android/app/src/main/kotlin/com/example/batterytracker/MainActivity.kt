package com.example.batterytracker

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresApi
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.app.AppOpsManager
import android.provider.Settings
import android.os.Process
import android.app.AlertDialog

//be very careful with this code, it can break everything if wrongly messed with
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.powermonitor/channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Check for permission on activity creation
        if (!hasUsageStatsPermission()) {
            showUsageStatsPermissionDialog()
        }
    }
    private fun showUsageStatsPermissionDialog() {
        AlertDialog.Builder(this)
            .setTitle("Usage Access Required")
            .setMessage("This app requires usage access to monitor battery consumption by apps. Please allow this permission in the next screen.")
            .setPositiveButton("OK") { dialog, which ->
                // Intent to open the usage access settings
                val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                startActivity(intent)
            }
            .setNegativeButton("Cancel", null)
            .create()
            .show()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getBatteryUsage") {
                val batteryUsage = getBatteryLevel()
                if (batteryUsage != null) {
                    result.success(batteryUsage)
                } else {
                    result.error("UNAVAILABLE", "Battery usage not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getBatteryLevel(): String {
        val batteryLevel: Int
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            applicationContext.registerReceiver(null, ifilter)
        }
        batteryLevel = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1

        val batteryPct = batteryLevel / scale.toFloat() * 100

        return "Battery level: $batteryPct%"
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
