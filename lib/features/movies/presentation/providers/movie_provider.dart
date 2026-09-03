import 'package:flutter/foundation.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

enum ViewState { initial, loading, loaded, error }

/// Un seul provider générique réutilisé pour les 3 écrans (Now Playing,
/// Popular, Top Rated) : chaque écran instancie le sien avec sa
/// [MovieCategory], ce qui évite de dupliquer 3x la même logique.
class MovieProvider extends ChangeNotifier {
  final MovieRepository repository;
  final MovieCategory category;

  MovieProvider({required this.repository, required this.category});

  ViewState state = ViewState.initial;
  List<Movie> movies = [];
  bool isFromCache = false;
  String? errorMessage;

  Future<void> load() async {
    state = ViewState.loading;
    notifyListeners();

    final result = await repository.getMovies(category);
    result.fold(
      (failure) {
        state = ViewState.error;
        errorMessage = failure.message;
      },
      (data) {
        state = ViewState.loaded;
        movies = data.movies;
        isFromCache = data.isFromCache;
      },
    );
    notifyListeners();
  }
}
