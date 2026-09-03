import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Résultat brut d'un login/register : le token ET l'utilisateur.
class AuthResult {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  AuthResult(
      {required this.user,
      required this.accessToken,
      required this.refreshToken});
}

abstract class AuthRemoteDataSource {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> register(
      {required String email, required String password});

  /// Simule un endpoint `/refresh`. ReqRes n'a pas de vrai refresh token :
  /// pour la démo, on ré-authentifie silencieusement avec les identifiants
  /// "fixture" et on considère le nouveau token comme le refresh.
  /// -> À REMPLACER par un vrai `POST /auth/refresh` sur un vrai backend.
  Future<String> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthResult> login(
      {required String email, required String password}) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      final token = response.data['token'] as String;
      return AuthResult(
        user: UserModel.fromLogin(id: token, email: email),
        accessToken: token,
        // ReqRes ne fournit pas de refresh token distinct : on en dérive un
        // pour illustrer le mécanisme (voir note dans refreshToken()).
        refreshToken: '$token-refresh',
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<AuthResult> register(
      {required String email, required String password}) async {
    try {
      final response = await dio.post(
        ApiConstants.registerEndpoint,
        data: {'email': email, 'password': password},
      );
      final token = response.data['token'] as String;
      final id = response.data['id']?.toString() ?? token;
      return AuthResult(
        user: UserModel(id: id, email: email),
        accessToken: token,
        refreshToken: '$token-refresh',
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    if (!refreshToken.endsWith('-refresh')) {
      throw AuthException('Refresh token invalide');
    }
    // Simulation : on "renouvelle" en réutilisant le token d'origine.
    return refreshToken.replaceAll('-refresh', '');
  }

  Exception _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException();
    }
    if (status == 400 || status == 401) {
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Identifiants invalides')
          : 'Identifiants invalides';
      return AuthException(msg.toString());
    }
    return ServerException(
      e.message ?? 'Erreur serveur inconnue',
      statusCode: status,
    );
  }
}
