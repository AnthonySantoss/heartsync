import 'package:flutter/services.dart';

class DeviceUsage {
  static const MethodChannel _channel = MethodChannel('com.example.heartsync/device_usage');

  static Future<bool> checkUsagePermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkUsagePermission');
      return hasPermission;
    } catch (e) {
      print('Erro ao verificar permissão: $e');
      return false;
    }
  }

  static Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } catch (e) {
      print('Erro ao solicitar permissão: $e');
    }
  }

  static Future<int> getDeviceUsageTimeWithPermission() async {
    final hasPermission = await checkUsagePermission();
    if (!hasPermission) {
      await requestUsagePermission();
      return 0; // Retorna 0 até que a permissão seja concedida
    }
    try {
      final int usageTime = await _channel.invokeMethod('getDeviceUsageTime');
      return usageTime;
    } catch (e) {
      print('Erro ao obter tempo de uso: $e');
      return 0;
    }
  }
}