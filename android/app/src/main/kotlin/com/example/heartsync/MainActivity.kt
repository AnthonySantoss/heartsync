package com.example.heartsync

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.heartsync/device_usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceUsageTime" -> {
                    val usageTime = getDeviceUsageTime()
                    if (usageTime != -1) {
                        result.success(usageTime)
                    } else {
                        result.error("UNAVAILABLE", "Não foi possível obter o tempo de uso.", null)
                    }
                }
                "checkUsagePermission" -> {
                    val hasPermission = checkUsagePermission()
                    result.success(hasPermission)
                }
                "requestUsagePermission" -> {
                    requestUsagePermission()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getDeviceUsageTime(): Int {
        if (!checkUsagePermission()) return -1
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis
        val endTime = System.currentTimeMillis()

        val usageStats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, startTime, endTime)
        var totalTimeInForeground = 0L

        for (stat in usageStats) {
            totalTimeInForeground += stat.totalTimeInForeground
        }

        return (totalTimeInForeground / 1000 / 60).toInt()
    }

    private fun checkUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsagePermission() {
        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }
}