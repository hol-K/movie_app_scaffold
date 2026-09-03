import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/movie_remote_data_source.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MovieListResult>> getMovies(
      MovieCategory category) async {
    final connected = await networkInfo.isConnected;

    // --- En ligne : on va chercher les données fraîches sur TMDB. ---
    if (connected) {
      try {
        final movies = await remoteDataSource.getMovies(category);
        // On rafraîchit le cache à chaque succès réseau, pour que le
        // prochain passage hors-ligne serve des données récentes.
        await localDataSource.cacheMovies(category, movies);
        return Right(MovieListResult(movies: movies, isFromCache: false));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(e.message));
      } on ServerException catch (e) {
        // Le serveur a répondu une erreur : on retombe sur le cache si
        // possible plutôt que d'afficher un écran vide.
        return _fallbackToCache(category, ServerFailure(e.message));
      } on NetworkException {
        return _fallbackToCache(category, const NetworkFailure());
      } catch (_) {
        return _fallbackToCache(category, const UnknownFailure());
      }
    }

    // --- Hors-ligne : on sert directement le cache. ---
    return _fallbackToCache(category, const NetworkFailure());
  }

  Future<Either<Failure, MovieListResult>> _fallbackToCache(
    MovieCategory category,
    Failure originalFailure,
  ) async {
    try {
      final cached = await localDataSource.getCachedMovies(category);
      return Right(MovieListResult(movies: cached, isFromCache: true));
    } on CacheException {
      // Ni réseau, ni cache : là on remonte vraiment un échec à l'UI.
      return Left(originalFailure);
    }
  }
}
