import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/movie_repository.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getMovies(MovieCategory category);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio dio;
  MovieRemoteDataSourceImpl(this.dio);

  String _endpointFor(MovieCategory category) => switch (category) {
        MovieCategory.nowPlaying => ApiConstants.nowPlayingEndpoint,
        MovieCategory.popular => ApiConstants.popularEndpoint,
        MovieCategory.topRated => ApiConstants.topRatedEndpoint,
      };

  @override
  Future<List<MovieModel>> getMovies(MovieCategory category) async {
    try {
      final response = await dio.get(
        _endpointFor(category),
        queryParameters: {'language': 'fr-FR', 'page': 1},
      );
      final results = response.data['results'] as List;
      return results
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      }
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ServerException(
        e.message ?? 'Erreur TMDB inconnue',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
