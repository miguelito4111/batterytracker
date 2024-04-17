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
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.util.Base64
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.powermonitor/channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (!hasUsageStatsPermission()) {
            showUsageStatsPermissionDialog()
        }
    }
private fun getIconBase64(packageName: String): String? {
    try {
        val pm = applicationContext.packageManager
        val iconDrawable = pm.getApplicationIcon(packageName)
        val bitmap = (iconDrawable as BitmapDrawable).bitmap
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        val bytes = outputStream.toByteArray()
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    } catch (e: Exception) {
        e.printStackTrace()
        return null
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

    fun formatDate(millis: Long): String {
        val formatter = SimpleDateFormat("MM/dd/yyyy HH:mm:ss", Locale.getDefault())
        return formatter.format(Date(millis))
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
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName")
                    val iconBase64 = getIconBase64(packageName!!)
                    if (iconBase64 != null) {
                        result.success(iconBase64)
                    } else {
                        result.error("ICON_NOT_FOUND", "Icon not found for package: $packageName", null)
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

    // Filtering out apps with LastTimeUsed == 0
    val filteredStats = usageStatsList.filter { it.lastTimeUsed > 0 }

    return if (filteredStats.isEmpty()) {
        "No usage stats available"
    } else {
        filteredStats.joinToString(separator = "\n") {
            "Pkg: ${it.packageName}, LastTimeUsed: ${formatDate(it.lastTimeUsed)}, TotalTimeForeground: ${it.totalTimeInForeground / 1000} seconds"
        }
    }
}
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }
}