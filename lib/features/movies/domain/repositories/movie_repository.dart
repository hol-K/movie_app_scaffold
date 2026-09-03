import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/movie.dart';

enum MovieCategory { nowPlaying, popular, topRated }

/// Enveloppe le résultat avec un flag `isFromCache` : la couche presentation
/// s'en sert pour afficher un bandeau "Mode hors-ligne" sans transformer
/// l'absence de réseau en erreur bloquante quand un cache existe.
class MovieListResult {
  final List<Movie> movies;
  final bool isFromCache;
  const MovieListResult({required this.movies, required this.isFromCache});
}

abstract class MovieRepository {
  Future<Either<Failure, MovieListResult>> getMovies(MovieCategory category);
}
