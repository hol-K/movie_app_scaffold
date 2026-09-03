import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('fr'));
  }

  bool get isEnglish => locale.languageCode == 'en';
  String get appTitle => 'MovieApp';
  String get login => isEnglish ? 'Sign in' : 'Se connecter';
  String get register => isEnglish ? 'Sign up' : "S'inscrire";
  String get noAccount => isEnglish ? 'No account? Sign up' : "Pas de compte ? S'inscrire";
  String get email => 'Email';
  String get password => isEnglish ? 'Password' : 'Mot de passe';
  String get invalidEmail => isEnglish ? 'Invalid email' : 'Email invalide';
  String get passwordTooShort => isEnglish ? 'Too short' : 'Trop court';
  String get logout => isEnglish ? 'Sign out' : 'Déconnexion';
  String get nowPlaying => isEnglish ? 'Now playing' : "À l'affiche";
  String get popular => isEnglish ? 'Popular' : 'Populaires';
  String get topRated => isEnglish ? 'Top rated' : 'Mieux notés';
  String get offline => isEnglish ? 'Offline mode - cached data' : 'Mode hors-ligne - données en cache';
  String get retry => isEnglish ? 'Retry' : 'Réessayer';
  String get noMovies => isEnglish ? 'No movies found.' : 'Aucun film trouvé.';
  String get noOverview => isEnglish ? 'No synopsis available.' : 'Pas de synopsis disponible.';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}