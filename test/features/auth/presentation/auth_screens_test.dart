import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/utils/either.dart';
import 'package:movie_app/features/auth/domain/entities/user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:movie_app/features/auth/presentation/screens/login_screen.dart';

class FakeAuthRepository implements AuthRepository {
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

Widget buildLogin() {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(FakeAuthRepository()),
    child: const MaterialApp(
      locale: Locale('fr'),
      home: LoginScreen(),
    ),
  );
}

void main() {
  testWidgets('login validates invalid email', (tester) async {
    await tester.pumpWidget(buildLogin());
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).first, 'invalid');
    await tester.tap(find.text('Se connecter'));
    await tester.pump();
    expect(find.text('Email invalide'), findsOneWidget);
  });

  testWidgets('login navigates to registration screen', (tester) async {
    await tester.pumpWidget(buildLogin());
    await tester.pump();
    await tester.tap(find.text("Pas de compte ? S'inscrire"));
    await tester.pumpAndSettle();
    expect(
        find.text('Démo : utilise un email fixture ReqRes '), findsOneWidget);
  });
}
