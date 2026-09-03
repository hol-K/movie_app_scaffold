import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/movie_repository.dart';
import '../providers/movie_provider.dart';
import 'movie_list_view.dart';

/// Écran 2/3 : "Populaires".
class PopularScreen extends StatelessWidget {
  const PopularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MovieProvider(
        repository: context.read<MovieRepository>(),
        category: MovieCategory.popular,
      ),
      child: const MovieListView(),
    );
  }
}
