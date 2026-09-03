import 'package:hive_flutter/hive_flutter.dart';

/// Noms des box Hive utilisées dans l'app.
/// On stocke volontairement du JSON (String) plutôt que des objets Hive
/// typés (`@HiveType`) : cela évite d'avoir besoin de `build_runner` /
/// génération de code pour faire tourner le projet "à froid".
class HiveBoxes {
  HiveBoxes._();
  static const String nowPlaying = 'cache_now_playing';
  static const String popular = 'cache_popular';
  static const String topRated = 'cache_top_rated';
}

Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.nowPlaying);
  await Hive.openBox<String>(HiveBoxes.popular);
  await Hive.openBox<String>(HiveBoxes.topRated);
}
