class User {
  final String serverId; // ID do backend (ex: MongoDB ObjectId string, ou UUID string)
  final int? localId;    // ID auto-incrementado do SQLite local (pode ser nulo se ainda não salvo)
  String name;
  String email;
  String? photoUrl;
  DateTime? birthDate;
  String? token; // Adicionado para consistência com DatabaseHelper, embora possa ser gerenciado separadamente

  User({
    required this.serverId, // Obrigatório ao vir do backend ou após registro
    this.localId,
    required this.name,
    required this.email,
    this.photoUrl,
    this.birthDate,
    this.token,
  });

  // Construtor para criar um usuário a partir de um mapa do SQLite
  factory User.fromDbMap(Map<String, dynamic> map) {
    DateTime? parsedBirthDate;
    if (map['birthDate'] != null && map['birthDate'] is String && (map['birthDate'] as String).isNotEmpty) {
      parsedBirthDate = DateTime.tryParse(map['birthDate'] as String);
    }
    return User(
      localId: map['id'] as int?,
      serverId: map['serverId'] as String, // serverId é esperado do DB local
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      birthDate: parsedBirthDate,
      token: map['token'] as String?, // Ler token se estiver no mapa do DB
    );
  }

  // Construtor para criar um usuário a partir de um JSON da API
  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parsedBirthDate;
    if (json['birthDate'] != null && json['birthDate'] is String && (json['birthDate'] as String).isNotEmpty) {
      parsedBirthDate = DateTime.tryParse(json['birthDate'] as String);
    }
    // O backend usa '_id' ou 'id'. O server.js usa '_id'.
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
      // localId e token não vêm diretamente do JSON da API de perfil (token vem do login/registro)
    );
  }

  // Método para converter o User para um Map para inserir/atualizar no SQLite
  Map<String, dynamic> toDbMap() {
    final map = <String, dynamic>{
      // 'id': localId, // O SQLite auto-incrementa 'id', não precisa enviar para insert se for nulo
      'serverId': serverId,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'birthDate': birthDate?.toIso8601String(),
      'token': token, // Salvar token no DB local
    };
    if (localId != null) {
      map['id'] = localId; // Inclui id para updates
    }
    return map;
  }

  // Método para converter o User para JSON para enviar ao backend (ex: update profile)
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
    // serverId e localId não são enviados no corpo do JSON para update,
    // o endpoint (ex: /users/:id) já identifica o usuário.
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
    bool setPhotoUrlToNull = false, // Para explicitamente setar photoUrl como null
    bool setBirthDateToNull = false, // Para explicitamente setar birthDate como null
  }) {
    return User(
      serverId: serverId ?? this.serverId,
      localId: localId ?? this.localId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: setPhotoUrlToNull ? null : (photoUrl ?? this.photoUrl),
      birthDate: setBirthDateToNull ? null : (birthDate ?? this.birthDate),
      token: token ?? this.token,
    );
  }
}