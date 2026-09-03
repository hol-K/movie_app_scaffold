import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

/// Client Dio pour l'API d'authentification. Ne dépend de rien d'autre :
/// c'est volontairement le premier maillon construit dans `main.dart`.
Dio buildAuthDio() {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstants.authBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        // ReqRes exige une clé API sur toutes les routes depuis 2025.
        'x-api-key': ApiConstants.reqresApiKey,
      },
    ),
  )..interceptors.add(LogInterceptor(responseBody: false));
}

/// Client Dio pour TMDB, avec injection du JWT applicatif + refresh
/// automatique via [authInterceptor]. Note pédagogique : TMDB lui-même
/// s'authentifie via `api_key` en query param (voir `BaseOptions` ci-dessous) ;
/// le Bearer token injecté par l'intercepteur représente la session de
/// *notre propre backend*, tel qu'on l'aurait avec une vraie API perso.
Dio buildMovieDio(AuthInterceptor authInterceptor) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.tmdbBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      queryParameters: {'api_key': ApiConstants.tmdbApiKey},
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(authInterceptor);
  dio.interceptors.add(LogInterceptor(responseBody: false));
  return dio;
}
