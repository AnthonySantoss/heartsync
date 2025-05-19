import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String name,
    required String birth,
    required String email,
    required String password,
    String? profileImagePath,
    required String heartCode,
    required String qrCodeUrl,
  }) : super(
    name: name,
    birth: birth,
    email: email,
    password: password,
    profileImagePath: profileImagePath,
    heartCode: heartCode,
    qrCodeUrl: qrCodeUrl,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      birth: json['birth'],
      email: json['email'],
      password: json['password'],
      profileImagePath: json['profileImagePath'],
      heartCode: json['heartCode'],
      qrCodeUrl: json['qrCodeUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birth': birth,
      'email': email,
      'password': password,
      'profileImagePath': profileImagePath,
      'heartCode': heartCode,
      'qrCodeUrl': qrCodeUrl,
    };
  }
}