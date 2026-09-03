import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/user.dart';

/// Le domaine ne connaît QUE cette interface : ni Dio, ni Hive, ni ReqRes.
/// `Either<Failure, T>` = soit un échec métier, soit la valeur attendue.
abstract class AuthRepository {
  Future<Either<Failure, User>> login(
      {required String email, required String password});
  Future<Either<Failure, User>> register(
      {required String email, required String password});
  Future<void> logout();
  Future<bool> isLoggedIn();
}
