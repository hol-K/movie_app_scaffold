import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider(this.authRepository) {
    _checkSession();
  }

  AuthStatus status = AuthStatus.unknown;
  User? currentUser;
  String? errorMessage;
  bool isLoading = false;

  Future<void> _checkSession() async {
    final logged = await authRepository.isLoggedIn();
    status = logged ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) => _submit(
        () => authRepository.login(email: email, password: password),
      );

  Future<bool> register(String email, String password) => _submit(
        () => authRepository.register(email: email, password: password),
      );

  Future<bool> _submit(Future<dynamic> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await action();
    var success = false;
    result.fold(
      (failure) => errorMessage = failure.message,
      (user) {
        currentUser = user as User;
        status = AuthStatus.authenticated;
        success = true;
      },
    );

    isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await authRepository.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
