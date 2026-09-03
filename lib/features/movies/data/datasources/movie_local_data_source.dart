import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/hive_init.dart';
import '../../domain/repositories/movie_repository.dart';
import '../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<void> cacheMovies(MovieCategory category, List<MovieModel> movies);
  Future<List<MovieModel>> getCachedMovies(MovieCategory category);
  Future<bool> hasCache(MovieCategory category);
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  String _boxNameFor(MovieCategory category) => switch (category) {
        MovieCategory.nowPlaying => HiveBoxes.nowPlaying,
        MovieCategory.popular => HiveBoxes.popular,
        MovieCategory.topRated => HiveBoxes.topRated,
      };

  Box<String> _box(MovieCategory category) =>
      Hive.box<String>(_boxNameFor(category));

  @override
  Future<void> cacheMovies(
      MovieCategory category, List<MovieModel> movies) async {
    try {
      final jsonList = movies.map((m) => m.toJson()).toList();
      await _box(category).put('data', jsonEncode(jsonList));
    } catch (e) {
      throw CacheException('Impossible de sauvegarder le cache : $e');
    }
  }

  @override
  Future<List<MovieModel>> getCachedMovies(MovieCategory category) async {
    final raw = _box(category).get('data');
    if (raw == null) {
      throw CacheException('Aucune donnée en cache pour $category');
    }
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> hasCache(MovieCategory category) async =>
      _box(category).containsKey('data');
}
