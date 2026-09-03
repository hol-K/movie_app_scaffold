import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/constants/api_constants.dart';
import 'core/network/auth_interceptor.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/movies/data/datasources/movie_local_data_source.dart';
import 'features/movies/data/datasources/movie_remote_data_source.dart';
import 'features/movies/data/repositories/movie_repository_impl.dart';
import 'features/movies/domain/repositories/movie_repository.dart';

/// Regroupe toutes les instances construites au démarrage de l'app.
/// C'est le seul endroit du projet qui "connaît" toutes les couches à la
/// fois — exactement le rôle d'une composition root en Clean Architecture.
class AppDependencies {
  final AuthRepositoryImpl authRepository;
  final MovieRepository movieRepository;

  AppDependencies({required this.authRepository, required this.movieRepository});

  factory AppDependencies.build() {
    // --- Stockage ---
    final tokenStorage = TokenStorage(const FlutterSecureStorage());

    // --- Auth (construit en premier : ne dépend de rien d'autre) ---
    final authDio = buildAuthDio();
    final authRemoteDataSource = AuthRemoteDataSourceImpl(authDio);
    final authLocalDataSource = AuthLocalDataSourceImpl(tokenStorage);
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    // --- Intercepteur (dépend du repository auth pour le refresh) ---
    final authInterceptor = AuthInterceptor(
      tokenStorage: tokenStorage,
      onRefreshToken: authRepository.refreshSession,
      baseUrl: ApiConstants.tmdbBaseUrl,
    );

    // --- Films ---
    final movieDio = buildMovieDio(authInterceptor);
    final movieRemoteDataSource = MovieRemoteDataSourceImpl(movieDio);
    final movieLocalDataSource = MovieLocalDataSourceImpl();
    final networkInfo = NetworkInfoImpl(Connectivity());
    final movieRepository = MovieRepositoryImpl(
      remoteDataSource: movieRemoteDataSource,
      localDataSource: movieLocalDataSource,
      networkInfo: networkInfo,
    );

    return AppDependencies(authRepository: authRepository, movieRepository: movieRepository);
  }
}
