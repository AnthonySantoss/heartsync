package com.example.heartsync

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.heartsync/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("UsageStats", "Erro ao abrir ACTION_USAGE_ACCESS_SETTINGS", e)
                        result.error("SETTINGS_ERROR", "Não foi possível abrir as configurações de acesso ao uso.", e.localizedMessage)
                    }
                }
                "getAppUsageStats" -> {
                    if (hasUsageStatsPermission()) {
                        val stats = getAppUsageStats()
                        result.success(stats)
                    } else {
                        result.error("PERMISSION_DENIED", "Permissão de acesso ao uso não concedida.", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getAppUsageStats(): List<Map<String, Any?>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis // Momento atual

        // Configurar startTime para a meia-noite de HOJE
        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        Log.d("UsageStatsNative", "Consultando dados de uso de: ${Date(startTime)} [${startTime}] até ${Date(endTime)} [${endTime}]")

        // Usando INTERVAL_BEST para obter a melhor granularidade no intervalo especificado
        val queryUsageStats: List<UsageStats>? = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_BEST,
            startTime,
            endTime
        )

        val appUsageList = mutableListOf<Map<String, Any?>>()
        if (queryUsageStats != null) {
            Log.d("UsageStatsNative", "Número de UsageStats retornados: ${queryUsageStats.size}")
            for (usageStat in queryUsageStats) {
                // Verificar se os timestamps estão dentro do intervalo do dia atual
                if (usageStat.firstTimeStamp >= startTime && usageStat.lastTimeStamp <= endTime && usageStat.totalTimeInForeground > 0) {
                    try {
                        val pm = applicationContext.packageManager
                        val appName = try {
                            val appInfo = pm.getApplicationInfo(usageStat.packageName, 0)
                            pm.getApplicationLabel(appInfo).toString()
                        } catch (e: PackageManager.NameNotFoundException) {
                            usageStat.packageName
                        }

                        Log.d("UsageStatsNative", "App: ${usageStat.packageName}, " +
                                "ForegroundTime: ${usageStat.totalTimeInForeground}ms, " +
                                "FirstTimestamp: ${Date(usageStat.firstTimeStamp)}, " +
                                "LastTimestamp: ${Date(usageStat.lastTimeStamp)}, " +
                                "Dentro do intervalo: ${usageStat.firstTimeStamp >= startTime && usageStat.lastTimeStamp <= endTime}")

                        val statMap = mapOf(
                            "packageName" to usageStat.packageName,
                            "appName" to appName,
                            "totalTimeInForeground" to usageStat.totalTimeInForeground,
                            "lastTimeUsed" to usageStat.lastTimeUsed
                        )
                        appUsageList.add(statMap)
                    } catch (e: Exception) {
                        Log.e("UsageStatsNative", "Erro ao processar ${usageStat.packageName}", e)
                    }
                } else {
                    Log.d("UsageStatsNative", "Ignorando ${usageStat.packageName}: fora do intervalo ou sem tempo de uso.")
                }
            }
        } else {
            Log.d("UsageStatsNative", "queryUsageStats retornou nulo.")
        }
        return appUsageList
    }
}