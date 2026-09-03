import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
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

  static const _screens = [
    NowPlayingScreen(),
    PopularScreen(),
    TopRatedScreen()
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final titles = [strings.nowPlaying, strings.popular, strings.topRated];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: strings.logout,
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.new_releases_outlined),
              label: strings.nowPlaying),
          NavigationDestination(
              icon: const Icon(Icons.trending_up), label: strings.popular),
          NavigationDestination(
              icon: const Icon(Icons.star_outline), label: strings.topRated),
        ],
      ),
    );
  }
}
