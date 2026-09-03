import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/movie_repository.dart';
import '../providers/movie_provider.dart';
import 'movie_list_view.dart';

/// Écran 1/3 : "À l'affiche". Instancie son propre [MovieProvider] scopé
/// à [MovieCategory.nowPlaying] via un Provider local (pas besoin de le
/// remonter au niveau app, chaque onglet est indépendant).
class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MovieProvider(
        repository: context.read<MovieRepository>(),
        category: MovieCategory.nowPlaying,
      ),
      child: const MovieListView(),
    );
  }
}
