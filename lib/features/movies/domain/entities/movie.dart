import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final double voteAverage;
  final String releaseDate;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  String get posterUrl =>
      posterPath == null ? '' : 'https://image.tmdb.org/t/p/w500$posterPath';

  @override
  List<Object?> get props => [id, title, overview, posterPath, voteAverage, releaseDate];
}
