/// Exceptions techniques levées dans la couche `data` (datasources).
/// Elles sont attrapées par les repositories et converties en [Failure]
/// (couche domain), qui elles seules remontent jusqu'à l'UI.
library;

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Pas de connexion internet']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Erreur de cache local']);
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Session expirée, reconnecte-toi']);
}
