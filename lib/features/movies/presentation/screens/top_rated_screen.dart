import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/movie_repository.dart';
import '../providers/movie_provider.dart';
import 'movie_list_view.dart';

/// Écran 3/3 : "Les mieux notés".
class TopRatedScreen extends StatelessWidget {
  const TopRatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MovieProvider(
        repository: context.read<MovieRepository>(),
        category: MovieCategory.topRated,
      ),
      child: const MovieListView(),
    );
  }
}
