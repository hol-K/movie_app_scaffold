import 'package:equatable/equatable.dart';

/// Représente un échec "métier", indépendant de la source technique.
/// C'est ce type que la couche `presentation` manipule — jamais les
/// exceptions brutes de `dio` ou `hive`.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Le serveur a rencontré une erreur.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Pas de connexion. Affichage des données en cache.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Aucune donnée en cache disponible.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Identifiants invalides.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Session expirée, merci de te reconnecter.',
  ]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inattendue est survenue.']);
}
