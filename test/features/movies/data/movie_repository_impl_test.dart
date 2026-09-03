import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/error/failures.dart';
import 'package:movie_app/core/network/network_info.dart';
import 'package:movie_app/features/movies/data/datasources/movie_local_data_source.dart';
import 'package:movie_app/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

class MockMovieLocalDataSource extends Mock implements MovieLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockMovieRemoteDataSource remote;
  late MockMovieLocalDataSource local;
  late MockNetworkInfo networkInfo;
  late MovieRepositoryImpl repository;

  const category = MovieCategory.popular;
  const movie = MovieModel(
    id: 1,
    title: 'Inception',
    overview: 'Un voleur qui s\'infiltre dans les rêves.',
    posterPath: '/poster.jpg',
    voteAverage: 8.4,
    releaseDate: '2010-07-16',
  );

  setUp(() {
    remote = MockMovieRemoteDataSource();
    local = MockMovieLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = MovieRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );
  });

  test('en ligne : va chercher les données distantes et met à jour le cache', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remote.getMovies(category)).thenAnswer((_) async => [movie]);
    when(() => local.cacheMovies(category, [movie])).thenAnswer((_) async {});

    final result = await repository.getMovies(category);

    expect(result.isRight, true);
    result.fold(
      (_) => fail('devrait être un succès'),
      (data) {
        expect(data.isFromCache, false);
        expect(data.movies, [movie]);
      },
    );
    verify(() => local.cacheMovies(category, [movie])).called(1);
  });

  test('hors-ligne avec cache disponible : sert le cache et marque isFromCache=true', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    when(() => local.getCachedMovies(category)).thenAnswer((_) async => [movie]);

    final result = await repository.getMovies(category);

    expect(result.isRight, true);
    result.fold(
      (_) => fail('devrait être un succès'),
      (data) {
        expect(data.isFromCache, true);
        expect(data.movies, [movie]);
      },
    );
    verifyNever(() => remote.getMovies(category));
  });

  test('hors-ligne sans cache : renvoie NetworkFailure', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => false);
    when(() => local.getCachedMovies(category)).thenThrow(CacheException());

    final result = await repository.getMovies(category);

    expect(result.isLeft, true);
    result.fold(
      (failure) => expect(failure, isA<NetworkFailure>()),
      (_) => fail('devrait être un échec'),
    );
  });

  test('en ligne mais erreur serveur avec cache dispo : retombe sur le cache', () async {
    when(() => networkInfo.isConnected).thenAnswer((_) async => true);
    when(() => remote.getMovies(category)).thenThrow(ServerException('500'));
    when(() => local.getCachedMovies(category)).thenAnswer((_) async => [movie]);

    final result = await repository.getMovies(category);

    expect(result.isRight, true);
    result.fold(
      (_) => fail('devrait être un succès (fallback cache)'),
      (data) => expect(data.isFromCache, true),
    );
  });
}
