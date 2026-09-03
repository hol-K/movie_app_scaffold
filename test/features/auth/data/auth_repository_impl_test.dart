import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:movie_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:movie_app/features/auth/data/models/user_model.dart';
import 'package:movie_app/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late AuthRepositoryImpl repository;

  const email = 'eve.holt@reqres.in';
  const password = 'cityslicka';

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    repository =
        AuthRepositoryImpl(remoteDataSource: remote, localDataSource: local);

    // Nécessaire à mocktail dès qu'un modèle custom est passé à un `any()`
    // dans un `when`/`verify` (pas utilisé dans ce fichier, mais bonne
    // pratique défensive si le fichier grossit).
    registerFallbackValue(const UserModel(id: '4', email: email));
  });

  group('login', () {
    test('renvoie un User et persiste la session en cas de succès', () async {
      // arrange
      final authResult = AuthResult(
        user: const UserModel(id: '4', email: email),
        accessToken: 'QpwL5tke4Pnpja7X4',
        refreshToken: 'QpwL5tke4Pnpja7X4-refresh',
      );
      when(() => remote.login(email: email, password: password))
          .thenAnswer((_) async => authResult);
      when(() => local.saveSession(
            user: any(named: 'user'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          )).thenAnswer((_) async {});

      // act
      final result = await repository.login(email: email, password: password);

      // assert
      expect(result.isRight, true);
      result.fold(
        (_) => fail('devrait être un succès'),
        (user) => expect(user.email, email),
      );
      verify(() => local.saveSession(
            user: authResult.user,
            accessToken: authResult.accessToken,
            refreshToken: authResult.refreshToken,
          )).called(1);
    });

    test('renvoie AuthFailure quand les identifiants sont invalides', () async {
      when(() => remote.login(email: email, password: 'wrong'))
          .thenThrow(AuthException('user not found'));

      final result = await repository.login(email: email, password: 'wrong');

      expect(result.isLeft, true);
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('devrait être un échec'),
      );
      // Aucune session ne doit être sauvegardée en cas d'échec.
      verifyNever(() => local.saveSession(
            user: any(named: 'user'),
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
          ));
    });

    test('renvoie NetworkFailure quand il n\'y a pas de connexion', () async {
      when(() => remote.login(email: email, password: password))
          .thenThrow(NetworkException());

      final result = await repository.login(email: email, password: password);

      expect(result.isLeft, true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('devrait être un échec'),
      );
    });
  });

  group('logout', () {
    test('délègue au datasource local et vide la session', () async {
      when(() => local.clearSession()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => local.clearSession()).called(1);
    });
  });

  group('isLoggedIn', () {
    test('reflète l\'état du datasource local', () async {
      when(() => local.hasSession()).thenAnswer((_) async => true);

      final result = await repository.isLoggedIn();

      expect(result, true);
    });
  });
}
