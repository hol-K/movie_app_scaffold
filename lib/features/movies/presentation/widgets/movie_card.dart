import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../screens/movie_detail_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
        ),
        contentPadding: const EdgeInsets.all(8),
        leading: SizedBox(
          width: 56,
          height: 80,
          child: movie.posterUrl.isEmpty
              ? const ColoredBox(color: Colors.black12, child: Icon(Icons.movie))
              : Image.network(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Colors.black12, child: Icon(Icons.broken_image)),
                ),
        ),
        title: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          movie.overview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            Text(movie.voteAverage.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}
