import '../../domain/entities/user.dart'; // Ajuste o path se necessário

// UserModel agora herda de User e pode ser usado para garantir type safety
// ou adicionar métodos específicos do data layer, se necessário.
// Para este caso, ele vai espelhar a entidade User.
class UserModel extends User {
  UserModel({
    required String serverId,
    int? localId,
    required String name,
    required String email,
    String? photoUrl,
    DateTime? birthDate,
    String? token,
  }) : super(
    serverId: serverId,
    localId: localId,
    name: name,
    email: email,
    photoUrl: photoUrl,
    birthDate: birthDate,
    token: token,
  );

  // Factory para criar UserModel a partir de um JSON da API.
  // Reutiliza a lógica de User.fromJson.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userEntity = User.fromJson(json);
    return UserModel(
      serverId: userEntity.serverId,
      localId: userEntity.localId, // Será null se o JSON for direto da API sem info local
      name: userEntity.name,
      email: userEntity.email,
      photoUrl: userEntity.photoUrl,
      birthDate: userEntity.birthDate,
      token: userEntity.token,     // Token geralmente não vem da API de 'profile', mas sim do login/auth.
      // Poderia ser adicionado ao UserModel se a API de perfil o retornasse.
    );
  }

  // Factory para criar UserModel a partir de um Map do banco de dados SQLite.
  // Reutiliza a lógica de User.fromDbMap.
  factory UserModel.fromDbMap(Map<String, dynamic> map) {
    final userEntity = User.fromDbMap(map);
    return UserModel(
      serverId: userEntity.serverId,
      localId: userEntity.localId,
      name: userEntity.name,
      email: userEntity.email,
      photoUrl: userEntity.photoUrl,
      birthDate: userEntity.birthDate,
      token: userEntity.token,
    );
  }

// Os métodos toJsonForApi() e toDbMap() são herdados diretamente da entidade User.
// Não há necessidade de sobrescrevê-los aqui a menos que haja lógica adicional
// específica para o UserModel.
}