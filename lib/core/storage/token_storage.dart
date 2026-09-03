import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encapsule `flutter_secure_storage` pour ne jamais manipuler les tokens
/// bruts ailleurs dans le code (Keychain sur iOS, Keystore sur Android).
class TokenStorage {
  final FlutterSecureStorage _storage;
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens(
      {required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> get hasSession async => (await accessToken) != null;
}
