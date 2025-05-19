// lib/domain/entities/partner_heart_code.dart
class PartnerHeartCode {
  final String code;
  final String userHeartCode; // Para comparar com o Heart Code do usuário

  PartnerHeartCode({
    required this.code,
    required this.userHeartCode,
  });
}