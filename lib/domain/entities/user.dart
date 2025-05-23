class User {
  final String serverId;
  final int? localId;
  String name;
  String email;
  String? photoUrl;
  DateTime? birthDate;
  String? token;
  DateTime? anniversaryDate;
  DateTime? syncDate;

  User({
    required this.serverId,
    this.localId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.birthDate,
    this.token,
    this.anniversaryDate,
    this.syncDate,
  });

  factory User.fromDbMap(Map<String, dynamic> map) {
    DateTime? parsedBirthDate;
    if (map['dataNascimento'] != null && map['dataNascimento'] is String && (map['dataNascimento'] as String).isNotEmpty) {
      parsedBirthDate = DateTime.tryParse(map['dataNascimento'] as String);
    }
    DateTime? parsedAnniversaryDate;
    if (map['anniversaryDate'] != null && map['anniversaryDate'] is String && (map['anniversaryDate'] as String).isNotEmpty) {
      parsedAnniversaryDate = DateTime.tryParse(map['anniversaryDate'] as String);
    }
    DateTime? parsedSyncDate;
    if (map['syncDate'] != null && map['syncDate'] is String && (map['syncDate'] as String).isNotEmpty) {
      parsedSyncDate = DateTime.tryParse(map['syncDate'] as String);
    }
    return User(
      localId: map['id'] as int?,
      serverId: map['serverId'] as String? ?? 'local-${map['id']}',
      name: map['nome'] as String,
      email: map['email'] as String,
      photoUrl: map['profileImagePath'] as String?,
      birthDate: parsedBirthDate,
      token: map['token'] as String?,
      anniversaryDate: parsedAnniversaryDate,
      syncDate: parsedSyncDate,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parsedBirthDate;
    if (json['birthDate'] != null && json['birthDate'] is String && (json['birthDate'] as String).isNotEmpty) {
      parsedBirthDate = DateTime.tryParse(json['birthDate'] as String);
    }
    DateTime? parsedAnniversaryDate;
    if (json['anniversaryDate'] != null && json['anniversaryDate'] is String && (json['anniversaryDate'] as String).isNotEmpty) {
      parsedAnniversaryDate = DateTime.tryParse(json['anniversaryDate'] as String);
    }
    DateTime? parsedSyncDate;
    if (json['syncDate'] != null && json['syncDate'] is String && (json['syncDate'] as String).isNotEmpty) {
      parsedSyncDate = DateTime.tryParse(json['syncDate'] as String);
    }
    final idFromJson = json['_id'] ?? json['id'];
    if (idFromJson == null || idFromJson is! String) {
      throw FormatException("ID do usuário inválido ou ausente no JSON da API: $json");
    }

    return User(
      serverId: idFromJson as String,
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      birthDate: parsedBirthDate,
      anniversaryDate: parsedAnniversaryDate,
      syncDate: parsedSyncDate,
    );
  }

  Map<String, dynamic> toDbMap() {
    final map = <String, dynamic>{
      'serverId': serverId,
      'nome': name,
      'email': email,
      'profileImagePath': photoUrl,
      'dataNascimento': birthDate?.toIso8601String(),
      'token': token,
      'anniversaryDate': anniversaryDate?.toIso8601String(),
      'syncDate': syncDate?.toIso8601String(),
    };
    if (localId != null) {
      map['id'] = localId;
    }
    return map;
  }

  Map<String, dynamic> toJsonForApi() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
    };
    if (photoUrl != null) {
      map['photoUrl'] = photoUrl;
    }
    if (birthDate != null) {
      map['birthDate'] = birthDate!.toIso8601String();
    }
    if (anniversaryDate != null) {
      map['anniversaryDate'] = anniversaryDate!.toIso8601String();
    }
    if (syncDate != null) {
      map['syncDate'] = syncDate!.toIso8601String();
    }
    return map;
  }

  User copyWith({
    String? serverId,
    int? localId,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? birthDate,
    String? token,
    DateTime? anniversaryDate,
    DateTime? syncDate,
    bool setPhotoUrlToNull = false,
    bool setBirthDateToNull = false,
    bool setAnniversaryDateToNull = false,
    bool setSyncDateToNull = false,
  }) {
    return User(
      serverId: serverId ?? this.serverId,
      localId: localId ?? this.localId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: setPhotoUrlToNull ? null : (photoUrl ?? this.photoUrl),
      birthDate: setBirthDateToNull ? null : (birthDate ?? this.birthDate),
      token: token ?? this.token,
      anniversaryDate: setAnniversaryDateToNull ? null : (anniversaryDate ?? this.anniversaryDate),
      syncDate: setSyncDateToNull ? null : (syncDate ?? this.syncDate),
    );
  }
}