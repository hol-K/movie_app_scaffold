import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
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
    final strings = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: () => context.read<MovieProvider>().load(),
      child: Column(
        children: [
          if (provider.isFromCache && provider.state == ViewState.loaded)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.offline,
                      style: const TextStyle(
                          color: Colors.deepOrange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(provider, strings)),
        ],
      ),
    );
  }

  Widget _buildBody(MovieProvider provider, AppLocalizations strings) {
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
                provider.errorMessage ?? strings.retry,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: provider.load,
                child: Text(strings.retry),
              ),
            ),
          ],
        );
      case ViewState.loaded:
        if (provider.movies.isEmpty) {
          return Center(child: Text(strings.noMovies));
        }
        return ListView.builder(
          itemCount: provider.movies.length,
          itemBuilder: (context, index) =>
              MovieCard(movie: provider.movies[index]),
        );
    }
  }
}
