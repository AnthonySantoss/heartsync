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

    // Esta é a função que calcula startTime e endTime internamente para "hoje"
    // e usa INTERVAL_BEST. É esta que queremos chamar do Dart.
    private fun getAppUsageStatsToday(): List<Map<String, Any?>> { // Renomeada para clareza, ou manter o nome original e ajustar o MethodChannel
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val calendar = Calendar.getInstance()
        val endTime = calendar.timeInMillis

        calendar.set(Calendar.HOUR_OF_DAY, 0)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        val startTime = calendar.timeInMillis

        Log.d("UsageStatsNative", "Consultando dados de uso (Hoje) de: ${Date(startTime)} [${startTime}] até ${Date(endTime)} [${endTime}] com INTERVAL_BEST")

        val queryUsageStats: List<UsageStats>? = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_BEST,
            startTime,
            endTime
        )

        val appUsageList = mutableListOf<Map<String, Any?>>()
        if (queryUsageStats != null) {
            Log.d("UsageStatsNative", "queryUsageStats (Hoje) retornou ${queryUsageStats.size} registros.")
            for (usageStat in queryUsageStats) {
                Log.d("UsageStatsNative", "App (Hoje): ${usageStat.packageName}, " +
                        "ForegroundTime: ${usageStat.totalTimeInForeground}ms, " +
                        "LastUsed: ${Date(usageStat.lastTimeUsed)}, " +
                        "FirstTimestamp: ${Date(usageStat.firstTimeStamp)}, " +
                        "LastTimestamp: ${Date(usageStat.lastTimeStamp)}")

                if (usageStat.totalTimeInForeground > 0) {
                    try {
                        val pm = applicationContext.packageManager
                        val appName = try {
                            val appInfo = pm.getApplicationInfo(usageStat.packageName, 0)
                            pm.getApplicationLabel(appInfo).toString()
                        } catch (e: PackageManager.NameNotFoundException) {
                            usageStat.packageName
                        }

                        val statMap = mapOf(
                            "packageName" to usageStat.packageName,
                            "appName" to appName,
                            "totalTimeInForeground" to usageStat.totalTimeInForeground,
                            "lastTimeUsed" to usageStat.lastTimeUsed
                        )
                        appUsageList.add(statMap)
                    } catch (e: Exception) {
                        Log.e("UsageStatsNative", "Erro ao processar ${usageStat.packageName} (Hoje)", e)
                    }
                }
            }
        } else {
            Log.d("UsageStatsNative", "queryUsageStats (Hoje) retornou nulo.")
        }
        return appUsageList
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            Log.e("UsageStatsNative", "Nenhuma atividade para lidar com ACTION_USAGE_ACCESS_SETTINGS")
                            result.error("NO_ACTIVITY", "Não foi possível encontrar uma atividade para ACTION_USAGE_ACCESS_SETTINGS.", null)
                        }
                    } catch (e: android.content.ActivityNotFoundException) {
                        Log.e("UsageStatsNative", "ActivityNotFoundException ao abrir ACTION_USAGE_ACCESS_SETTINGS", e)
                        result.error("NO_ACTIVITY_HANDLER", "Não foi possível abrir as configurações de acesso ao uso (ActivityNotFound).", e.localizedMessage)
                    }
                    catch (e: Exception) {
                        Log.e("UsageStatsNative", "Erro ao abrir ACTION_USAGE_ACCESS_SETTINGS", e)
                        result.error("SETTINGS_ERROR", "Não foi possível abrir as configurações de acesso ao uso.", e.localizedMessage)
                    }
                }
                // --- CORREÇÃO APLICADA AQUI ---
                // Este é o método que o DeviceUsageService do Dart chama.
                // Ele não espera argumentos de tempo, pois são calculados internamente.
                "getAppUsageStats" -> { // Nome do método corresponde ao Dart
                    if (hasUsageStatsPermission()) {
                        val stats = getAppUsageStatsToday() // Chama a função correta
                        result.success(stats)
                    } else {
                        result.error("PERMISSION_DENIED", "Permissão de acesso ao uso não concedida.", null)
                    }
                }
                // Se você ainda precisar da função que recebe startTime e endTime do Dart
                // para outros propósitos, pode mantê-la com um nome de método diferente no channel.
                // Exemplo: "getUsageStatsForInterval"
                /*
                "getUsageStatsForInterval" -> { // Exemplo de nome diferente se precisar manter a outra função
                    val startTime = call.argument<Long>("startTime")
                    val endTime = call.argument<Long>("endTime")
                    if (startTime != null && endTime != null) {
                        // Aqui você chamaria a função getUsageStats(startTime, endTime) que você tinha
                        // e que usa INTERVAL_DAILY. Por ora, vou comentar pois o foco é "hoje".
                        // val stats = getUsageStats(startTime, endTime)
                        // result.success(stats)
                        result.notImplemented() // Implementar se necessário
                    } else {
                        result.error("INVALID_ARGUMENTS", "startTime ou endTime nulos para getUsageStatsForInterval.", null)
                    }
                }
                */
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

    // A função getUsageStats(startTime: Long, endTime: Long) que usa INTERVAL_DAILY
    // foi implicitamente substituída/corrigida pela getAppUsageStatsToday() para o propósito
    // de buscar os dados do "dia atual". Se você precisar de uma função que aceite
    // um intervalo arbitrário do Dart, você deveria recriá-la e chamá-la com um nome de método diferente
    // no MethodChannel (como o exemplo "getUsageStatsForInterval" acima).
}
