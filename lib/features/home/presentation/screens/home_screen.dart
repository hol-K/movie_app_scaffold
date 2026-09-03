import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../movies/presentation/screens/now_playing_screen.dart';
import '../../../movies/presentation/screens/popular_screen.dart';
import '../../../movies/presentation/screens/top_rated_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['À l\'affiche', 'Populaires', 'Mieux notés'];
  static const _screens = [NowPlayingScreen(), PopularScreen(), TopRatedScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.new_releases_outlined), label: 'À l\'affiche'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Populaires'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'Mieux notés'),
        ],
      ),
    );
  }
}
