import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/storage/hive_init.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();

  final deps = AppDependencies.build();

  runApp(MyApp(deps: deps));
}

class MyApp extends StatelessWidget {
  final AppDependencies deps;
  const MyApp({super.key, required this.deps});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: deps.movieRepository),
        ChangeNotifierProvider(create: (_) => AuthProvider(deps.authRepository)),
      ],
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr'), Locale('en')],
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const _RootRouter(),
      ),
    );
  }
}

/// Bascule entre l'écran de connexion et l'écran principal selon l'état
/// d'authentification. Le splash "unknown" évite un flash de l'écran de
/// login pendant que la session est vérifiée au démarrage.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthProvider>().status;
    return switch (status) {
      AuthStatus.unknown => const Scaffold(body: Center(child: CircularProgressIndicator())),
      AuthStatus.unauthenticated => const LoginScreen(),
      AuthStatus.authenticated => const HomeScreen(),
    };
  }
}
