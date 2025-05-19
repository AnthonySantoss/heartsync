import 'dart:math';
import 'package:heartsync/domain/entities/user.dart';
import '../../core/errors/exceptions.dart';

abstract class HeartCodeRemoteDataSource {
  Future<User> generateHeartCode({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
  });
}

class HeartCodeRemoteDataSourceImpl implements HeartCodeRemoteDataSource {
  @override
  Future<User> generateHeartCode({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    try {
      // Simula latência de uma chamada remota
      await Future.delayed(const Duration(seconds: 2));

      // Gera um heartCode: 7 números + 2 letras maiúsculas
      final random = Random();
      String numbers = List.generate(7, (_) => random.nextInt(10)).join();
      String letters = String.fromCharCodes(
        List.generate(2, (_) => 65 + random.nextInt(26)), // Letras de A-Z
      );
      final heartCode = '$numbers$letters';

      // Gera a URL do QR Code usando qrserver.com
      final qrCodeUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$heartCode';

      return User(
        name: name,
        birth: birth,
        email: email,
        password: password,
        profileImagePath: profileImagePath,
        heartCode: heartCode,
        qrCodeUrl: qrCodeUrl,
      );
    } catch (e) {
      throw ServerException();
    }
  }
}