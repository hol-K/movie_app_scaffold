import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

/// Signature du callback de rafraîchissement, injecté depuis la couche auth
/// (voir `AuthRepositoryImpl.refreshSession`). On évite ainsi que `core/`
/// dépende de `features/auth/` — dépendance inversée, comme en Clean Arch.
typedef RefreshTokenCallback = Future<String?> Function(String refreshToken);

/// Intercepteur Dio responsable de :
///  1. Injecter le header `Authorization: Bearer <token>` sur chaque requête.
///  2. Intercepter les 401, tenter un refresh du token, puis rejouer
///     UNE SEULE FOIS la requête originale (garde-fou anti boucle infinie).
///  3. Si le refresh échoue, purger la session (déconnexion forcée).
class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final RefreshTokenCallback onRefreshToken;
  final Dio _retryDio; // instance dédiée, sans intercepteur, pour le replay

  AuthInterceptor({
    required this.tokenStorage,
    required this.onRefreshToken,
    required String baseUrl,
    Dio? retryDio,
  }) : _retryDio = retryDio ?? Dio(BaseOptions(baseUrl: baseUrl));

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;

    if (isUnauthorized && !alreadyRetried) {
      final refreshToken = await tokenStorage.refreshToken;
      if (refreshToken != null) {
        try {
          final newAccessToken = await onRefreshToken(refreshToken);
          if (newAccessToken != null) {
            await tokenStorage.saveTokens(accessToken: newAccessToken);

            // On rejoue la requête originale avec le nouveau token.
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            retryOptions.extra['retried'] = true;

            final response = await _retryDio.fetch(retryOptions);
            return handler.resolve(response);
          }
        } catch (_) {
          // Le refresh a échoué -> on tombe dans la purge de session ci-dessous.
        }
      }
      // Refresh impossible ou échoué : on purge la session locale.
      // L'écran d'auth écoute `AuthProvider` et redirige vers le login.
      await tokenStorage.clear();
    }

    handler.next(err);
  }
}
