import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(
      {required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, User>> login(
      {required String email, required String password}) async {
    try {
      final result =
          await remoteDataSource.login(email: email, password: password);
      await localDataSource.saveSession(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return Right(result.user);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, User>> register(
      {required String email, required String password}) async {
    try {
      final result =
          await remoteDataSource.register(email: email, password: password);
      await localDataSource.saveSession(
        user: result.user,
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return Right(result.user);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<void> logout() => localDataSource.clearSession();

  @override
  Future<bool> isLoggedIn() => localDataSource.hasSession();

  /// Appelé par [AuthInterceptor] quand une requête reçoit un 401.
  /// Retourne le nouveau access token, ou `null` si le refresh échoue.
  Future<String?> refreshSession(String refreshToken) async {
    try {
      return await remoteDataSource.refreshToken(refreshToken);
    } catch (_) {
      return null;
    }
  }
}
