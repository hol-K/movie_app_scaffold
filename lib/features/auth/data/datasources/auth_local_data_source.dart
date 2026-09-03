import '../../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveSession({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  });
  Future<UserModel?> getCachedUser();
  Future<void> clearSession();
  Future<bool> hasSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorage tokenStorage;
  // Email/id de l'utilisateur courant, stockés à côté des tokens pour
  // pouvoir réafficher "Connecté en tant que ..." même hors-ligne.
  UserModel? _cachedUser;

  AuthLocalDataSourceImpl(this.tokenStorage);

  @override
  Future<void> saveSession({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await tokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    _cachedUser = user;
  }

  @override
  Future<UserModel?> getCachedUser() async => _cachedUser;

  @override
  Future<void> clearSession() async {
    await tokenStorage.clear();
    _cachedUser = null;
  }

  @override
  Future<bool> hasSession() => tokenStorage.hasSession;
}
