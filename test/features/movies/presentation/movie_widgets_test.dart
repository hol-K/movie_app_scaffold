import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/widgets/movie_card.dart';

const testMovie = Movie(
  id: 1,
  title: 'Test Movie',
  overview: 'A test overview',
  posterPath: null,
  voteAverage: 8.5,
  releaseDate: '2026-01-01',
);

void main() {
  testWidgets('movie card displays title and rating', (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: MovieCard(movie: testMovie)));
    expect(find.text('Test Movie'), findsOneWidget);
    expect(find.text('8.5'), findsOneWidget);
  });

  testWidgets('movie card exposes poster semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester
        .pumpWidget(const MaterialApp(home: MovieCard(movie: testMovie)));
    expect(
      tester.getSemantics(find.byType(MovieCard)),
      matchesSemantics(label: 'Film Test Movie', isButton: true),
    );
    semantics.dispose();
  });
}
