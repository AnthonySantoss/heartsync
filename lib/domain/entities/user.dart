class User {
  final String name;
  final String birth;
  final String email;
  final String password;
  final String? profileImagePath;
  final String heartCode;
  final String qrCodeUrl;

  User({
    required this.name,
    required this.birth,
    required this.email,
    required this.password,
    this.profileImagePath,
    required this.heartCode,
    required this.qrCodeUrl,
  });
}