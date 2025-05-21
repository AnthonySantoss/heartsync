import 'dart:math';
import 'package:heartsync/domain/entities/partner_heart_code.dart';
import 'package:heartsync/domain/entities/user.dart';
import '../../core/errors/exceptions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class HeartCodeRemoteDataSource {
  Future<User> generateHeartCode({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
  });

  Future<PartnerHeartCode> validatePartnerHeartCode({
    required String partnerHeartCode,
    required String userHeartCode,
  });
}

class HeartCodeRemoteDataSourceImpl implements HeartCodeRemoteDataSource {
  final String baseUrl = 'http://your-backend-url:3000'; // Substitua pelo URL do seu backend

  @override
  Future<User> generateHeartCode({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': name,
          'email': email,
          'dataNascimento': birth,
          'senha': password,
          'temFoto': profileImagePath != null,
          'profileImagePath': profileImagePath,
          'heartcode': '${Random().nextInt(9999999).toString().padLeft(7, '0')}${String.fromCharCodes(List.generate(2, (_) => 65 + Random().nextInt(26)))}',
          'conectado': false,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final heartCode = data['heartcode'];
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
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<PartnerHeartCode> validatePartnerHeartCode({
    required String partnerHeartCode,
    required String userHeartCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate-heartcode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userHeartCode': userHeartCode,
          'partnerHeartCode': partnerHeartCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PartnerHeartCode(
          code: partnerHeartCode,
          userHeartCode: userHeartCode,
          codigoConexao: data['codigoConexao'], // Obtido do backend
        );
      } else {
        throw ServerException();
      }
    } catch (e) {
      throw ServerException();
    }
  }
}

class InvalidHeartCodeException implements Exception {}