import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: movie.posterUrl.isEmpty
                  ? const ColoredBox(color: Colors.black26)
                  : Image.network(movie.posterUrl, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${movie.voteAverage.toStringAsFixed(1)} / 10'),
                      const SizedBox(width: 16),
                      Text(movie.releaseDate),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    movie.overview.isEmpty ? 'Pas de synopsis disponible.' : movie.overview,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
