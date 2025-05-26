package com.example.heartsync

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
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

    /**
     * Verifica se um aplicativo possui a flag FLAG_SYSTEM.
     */
    private fun isFlaggedAsSystemApp(pm: PackageManager, packageName: String): Boolean {
        return try {
            val appInfo = pm.getApplicationInfo(packageName, 0)
            (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
        } catch (e: PackageManager.NameNotFoundException) {
            Log.w("UsageStatsNative", "PackageName $packageName not found for isFlaggedAsSystemApp, assuming system for safety.")
            true // Considera como sistema se não encontrado, para ser potencialmente filtrado.
        }
    }

    /**
     * Verifica se um aplicativo pode ser lançado pelo usuário (possui uma LAUNCHER activity).
     */
    private fun canBeLaunchedByUser(pm: PackageManager, packageName: String): Boolean {
        val intent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
            this.setPackage(packageName)
        }
        // Se queryIntentActivities retornar uma lista não vazia, significa que há pelo menos uma atividade de launcher.
        val resolveInfoList = pm.queryIntentActivities(intent, 0)
        return resolveInfoList.isNotEmpty()
    }


    private fun getAppUsageStatsToday(): List<Map<String, Any?>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val pm = applicationContext.packageManager

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
                if (usageStat.totalTimeInForeground > 0) { // Apenas apps que foram usados
                    try {
                        val packageName = usageStat.packageName
                        val appName = try {
                            val appInfo = pm.getApplicationInfo(packageName, 0)
                            pm.getApplicationLabel(appInfo).toString()
                        } catch (e: PackageManager.NameNotFoundException) {
                            packageName // Fallback para o nome do pacote
                        }

                        val isActuallyFlaggedAsSystem = isFlaggedAsSystemApp(pm, packageName)
                        val isLaunchable = canBeLaunchedByUser(pm, packageName)

                        // Lógica de filtro:
                        // Um app deve ser filtrado (considerado "sistema puro" para nossa contagem) se:
                        // Ele TEM a flag de sistema (isActuallyFlaggedAsSystem = true)
                        // E NÃO PODE ser lançado pelo usuário (isLaunchable = false)
                        val shouldBeFilteredOutOfUsage = isActuallyFlaggedAsSystem && !isLaunchable

                        val statMap = mapOf(
                            "packageName" to packageName,
                            "appName" to appName,
                            "totalTimeInForeground" to usageStat.totalTimeInForeground,
                            "lastTimeUsed" to usageStat.lastTimeUsed,
                            // "isSystemApp" para o Dart agora significa "este app deve ser filtrado da contagem?"
                            "isSystemApp" to shouldBeFilteredOutOfUsage
                        )
                        appUsageList.add(statMap)

                        // Log detalhado para depuração da lógica de filtro
                        Log.d("UsageStatsNative", "App: $appName ($packageName), FlaggedSystem: $isActuallyFlaggedAsSystem, Launchable: $isLaunchable, FilterOut: $shouldBeFilteredOutOfUsage, Time: ${usageStat.totalTimeInForeground}ms")

                    } catch (e: Exception) {
                        Log.e("UsageStatsNative", "Erro ao processar $packageName (Hoje)", e)
                    }
                }
            }
        } else {
            Log.d("UsageStatsNative", "queryUsageStats (Hoje) retornou nulo.")
        }
        Log.d("UsageStatsNative", "Total de apps processados e adicionados (com tempo > 0): ${appUsageList.size}")
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
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        if (intent.resolveActivity(packageManager) != null) {
                            applicationContext.startActivity(intent)
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
                "getAppUsageStats" -> {
                    if (hasUsageStatsPermission()) {
                        val stats = getAppUsageStatsToday()
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
        // O OPSTR_GET_USAGE_STATS requer API level 21 (Lollipop). Seu minSdkVersion é 16.
        // AppOpsManager.OPSTR_GET_USAGE_STATS só está disponível a partir do API 21.
        // Se for rodar em API < 21, esta checagem pode precisar de fallback ou o app não funcionará.
        // No entanto, UsageStatsManager também é API 21+, então seu app já tem esse requisito.
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }
}