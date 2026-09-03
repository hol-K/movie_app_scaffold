import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

/// Widget commun aux 3 écrans de données : gère l'affichage des états
/// (chargement, erreur, hors-ligne, succès) au-dessus d'un [MovieProvider]
/// déjà injecté plus haut dans l'arbre. Évite de dupliquer ce switch dans
/// chacun des 3 écrans.
class MovieListView extends StatefulWidget {
  const MovieListView({super.key});

  @override
  State<MovieListView> createState() => _MovieListViewState();
}

class _MovieListViewState extends State<MovieListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return RefreshIndicator(
      onRefresh: () => context.read<MovieProvider>().load(),
      child: Column(
        children: [
          if (provider.isFromCache && provider.state == ViewState.loaded)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode hors-ligne — données en cache',
                      style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(MovieProvider provider) {
    switch (provider.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return ListView(
          // ListView (pas Column) pour que le pull-to-refresh marche même
          // en état d'erreur.
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                provider.errorMessage ?? 'Une erreur est survenue',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: provider.load,
                child: const Text('Réessayer'),
              ),
            ),
          ],
        );
      case ViewState.loaded:
        if (provider.movies.isEmpty) {
          return const Center(child: Text('Aucun film trouvé.'));
        }
        return ListView.builder(
          itemCount: provider.movies.length,
          itemBuilder: (context, index) =>
              MovieCard(movie: provider.movies[index]),
        );
    }
  }
}
