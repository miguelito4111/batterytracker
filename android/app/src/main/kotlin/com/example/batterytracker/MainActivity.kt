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
import java.util.Calendar

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.powermonitor/channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (!hasUsageStatsPermission()) {
            showUsageStatsPermissionDialog()
        }
    }

    private fun showUsageStatsPermissionDialog() {
        AlertDialog.Builder(this)
            .setTitle("Usage Access Required")
            .setMessage("This app requires usage access to monitor battery consumption by apps. Please allow this permission in the next screen.")
            .setPositiveButton("OK") { dialog, which ->
                val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                startActivity(intent)
            }
            .setNegativeButton("Cancel", null)
            .create()
            .show()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryUsage" -> {
                    val batteryUsage = getBatteryLevel()
                    if (batteryUsage != null) {
                        result.success(batteryUsage)
                    } else {
                        result.error("UNAVAILABLE", "Battery usage not available.", null)
                    }
                }
                "getAppUsageStats" -> {
                    val appUsageStats = getAppUsageStats()
                    if (appUsageStats.isNotEmpty()) {
                        result.success(appUsageStats)
                    } else {
                        result.error("NO_STATS", "No usage stats available", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getBatteryLevel(): String {
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
            applicationContext.registerReceiver(null, ifilter)
        }
        val batteryLevel = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1

        return "Battery level: ${batteryLevel / scale.toFloat() * 100}%"
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun getAppUsageStats(): String {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val beginTime = endTime - 1000 * 60 * 60 * 24 * 365 // Last year
        val usageStatsList = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, beginTime, endTime)
        return usageStatsList.joinToString(separator = "\n") {
            "Pkg: ${it.packageName}, LastTimeUsed: ${it.lastTimeUsed}, TotalTimeForeground: ${it.totalTimeInForeground / 1000} seconds"
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
