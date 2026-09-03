import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/utils/either.dart';
import 'package:movie_app/features/auth/domain/entities/user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/injection.dart';
import 'package:movie_app/main.dart';

class IntegrationAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> login(
          {required String email, required String password}) async =>
      const Right(User(id: '1', email: 'test@example.com'));
  @override
  Future<Either<Failure, User>> register(
          {required String email, required String password}) async =>
      const Right(User(id: '1', email: 'test@example.com'));
  @override
  Future<void> logout() async {}
  @override
  Future<bool> isLoggedIn() async => false;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies(
    authRepository: IntegrationAuthRepository(),
    movieRepository: _EmptyMovieRepository(),
  );

  testWidgets('starts on the login screen', (tester) async {
    await tester
        .pumpWidget(MyApp(deps: dependencies, locale: const Locale('fr')));
    await tester.pumpAndSettle();
    expect(find.text('MovieApp'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('shows validation feedback during the login flow',
      (tester) async {
    await tester
        .pumpWidget(MyApp(deps: dependencies, locale: const Locale('fr')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'bad');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Email invalide'), findsOneWidget);
  });
}

class _EmptyMovieRepository implements MovieRepository {
  @override
  Future<Either<Failure, MovieListResult>> getMovies(
          MovieCategory category) async =>
      const Right(MovieListResult(movies: [], isFromCache: false));
}
