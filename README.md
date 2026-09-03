# MovieApp

[![CI](https://github.com/hol-K/movie_app_scaffold/actions/workflows/ci.yml/badge.svg?branch=other)](https://github.com/hol-K/movie_app_scaffold/actions/workflows/ci.yml?query=branch%3Aother)

Application Flutter de découverte de films basée sur TMDB, avec authentification de démonstration ReqRes. Le projet est organisé selon une architecture Clean et une structure Feature-First.

## Fonctionnalités

- Connexion, inscription et déconnexion
- Session conservée dans `flutter_secure_storage`
- Films à l'affiche, populaires et mieux notés
- Détail d'un film
- Cache Hive et fonctionnement hors ligne
- Rejeu d'une requête après expiration de session
- Interface française et anglaise
- Labels d'accessibilité pour les contenus et actions principales

L'application comporte les écrans de connexion, d'inscription, d'accueil, de listes de films et de détail d'un film. L'accueil propose trois catégories de films.

## Captures d'écran

Les captures de l'application sont à ajouter dans `docs/screenshots/` après une exécution locale. Les captures recommandées sont `login.png`, `home.png`, `movie-list.png` et `movie-detail.png`.

## Architecture

```text
lib/
├── core/
│   ├── constants/       URLs et configuration des APIs
│   ├── error/           exceptions et failures métier
│   ├── localization/    chaînes françaises et anglaises
│   ├── network/         clients Dio, intercepteur et connectivité
│   ├── storage/         Hive et stockage sécurisé
│   └── utils/           types utilitaires
├── features/
│   ├── auth/            domain, data et presentation de l'authentification
│   ├── home/            navigation principale
│   └── movies/          domain, data et presentation des films
├── injection.dart       composition des dépendances
└── main.dart            point d'entrée
```

La règle de dépendance est `presentation -> domain <- data`. Le domaine ne dépend ni de Dio, ni de Hive, ni des APIs externes. Les repositories choisissent entre les données distantes et le cache local.

## APIs

| API                                                  | Utilisation                       |
| ---------------------------------------------------- | --------------------------------- |
| [TMDB](https://www.themoviedb.org/documentation/api) | Films, détails et images          |
| [ReqRes](https://reqres.in)                          | Authentification de démonstration |

Compte de démonstration ReqRes : `eve.holt@reqres.in` / `cityslicka`.

## Installation et configuration

Prérequis : Flutter et Dart compatibles avec [pubspec.yaml](pubspec.yaml), une clé TMDB et une clé ReqRes.

```powershell
flutter pub get
Copy-Item dart_defines.example.json dart_defines.local.json
```

Renseigner ensuite `TMDB_API_KEY` et `REQRES_API_KEY` dans `dart_defines.local.json`. Ce fichier est ignoré par Git et ne doit jamais être publié.

## Lancer l'application

```powershell
flutter run -d chrome --dart-define-from-file=dart_defines.local.json
```

Le script `run.ps1` applique cette configuration automatiquement.

## Tests et qualité

```powershell
flutter analyze
flutter test
```

La suite actuelle comprend 15 tests unitaires et 5 tests widgets. Les deux tests d'intégration web utilisent ChromeDriver :

```powershell
chromedriver --port=4444
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_flow_test.dart -d chrome
```

Le workflow GitHub Actions exécute le formatage, `flutter analyze`, les tests avec couverture et les builds mobiles. Chaque exécution publie un APK Android debug et une archive iOS non signée comme artefacts téléchargeables.

## Performance et accessibilité

Les listes utilisent `ListView.builder`, les affiches utilisent des dimensions de cache adaptées, et les widgets statiques utilisent `const` lorsque cela est compatible avec la localisation. Les cartes et images exposent des informations sémantiques aux lecteurs d'écran.

## Dépôt et versions

- Dépôt : https://github.com/hol-K/movie_app_scaffold
- Branche de livraison : `other`
- Historique : [CHANGELOG.md](CHANGELOG.md)
- CI : [GitHub Actions](https://github.com/hol-K/movie_app_scaffold/actions)
