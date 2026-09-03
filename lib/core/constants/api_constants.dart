/// Toutes les constantes réseau du projet sont centralisées ici.
///
/// ⚠️ NE JAMAIS committer une vraie clé API en dur dans un repo public.
/// En pratique, ces valeurs devraient venir de `--dart-define` ou d'un
/// fichier `.env` ignoré par git (voir README, section "Configuration").
class ApiConstants {
  ApiConstants._();

  // ---------------------------------------------------------------------
  // TMDB (The Movie Database) — source des données "métier" (films).
  // Clé gratuite à générer sur https://www.themoviedb.org/settings/api
  // ---------------------------------------------------------------------
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbApiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: 'YOUR_TMDB_API_KEY',
  );

  static const String nowPlayingEndpoint = '/movie/now_playing';
  static const String popularEndpoint = '/movie/popular';
  static const String topRatedEndpoint = '/movie/top_rated';
  static String movieDetailEndpoint(int id) => '/movie/$id';

  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // ---------------------------------------------------------------------
  // ReqRes — API factice utilisée pour la démonstration du flux
  // d'authentification (login/register). Depuis 2025, ReqRes exige une
  // clé API gratuite : voir https://app.reqres.in
  //
  // Pour un vrai projet, remplace `AuthRemoteDataSource` par un appel à
  // ton propre backend (Node/Express, Supabase Auth, Firebase Auth...).
  // Le reste de l'architecture (repository, provider, écrans) ne bouge pas.
  // ---------------------------------------------------------------------
  static const String authBaseUrl = 'https://reqres.in/api';
  static const String reqresApiKey = String.fromEnvironment(
    'REQRES_API_KEY',
    defaultValue: 'YOUR_REQRES_API_KEY',
  );
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
