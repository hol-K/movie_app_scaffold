import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.id, required super.email});

  factory UserModel.fromLogin({required String id, required String email}) =>
      UserModel(id: id, email: email);

  factory UserModel.fromJson(Map<String, dynamic> json,
      {required String email}) {
    // ReqRes /login et /register ne renvoient qu'un id + token, pas l'email
    // en retour -> on le reporte depuis la requête d'origine.
    return UserModel(id: json['id']?.toString() ?? '0', email: email);
  }

  Map<String, dynamic> toJson() => {'id': id, 'email': email};
}
