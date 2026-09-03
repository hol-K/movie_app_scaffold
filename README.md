# MovieApp

Application Flutter de découverte de films basée sur TMDB, avec authentification de démonstration ReqRes. Le projet suit une architecture Clean, organisée par fonctionnalité.

## Fonctionnalités

- Connexion, inscription et déconnexion
- Conservation sécurisée de la session
- Films à l'affiche, populaires et mieux notés
- Détail d'un film
- Cache Hive et fonctionnement hors ligne
- Rejeu d'une requête après expiration de session
- Interface disponible en français et en anglais
- Labels d'accessibilité pour les contenus et actions principales

L'application contient au moins cinq écrans : connexion, inscription, accueil, liste des films et détail d'un film. L'accueil comprend trois catégories de films.

## APIs

| API                                                  | Utilisation                       |
| ---------------------------------------------------- | --------------------------------- |
| [TMDB](https://www.themoviedb.org/documentation/api) | Films, détails et images          |
| [ReqRes](https://reqres.in)                          | Authentification de démonstration |

Le compte de démonstration ReqRes pour la connexion est `eve.holt@reqres.in` avec le mot de passe `cityslicka`.

## Prérequis

- Flutter et Dart compatibles avec `pubspec.yaml`
- Une clé API TMDB
- Une clé API ReqRes

## Configuration

Copier le fichier d'exemple et renseigner les clés :

```powershell
Copy-Item dart_defines.example.json dart_defines.local.json
```

Le fichier `dart_defines.local.json` est ignoré par Git. Ne publie jamais ses clés.

## Lancer l'application

```powershell
flutter pub get
flutter run -d chrome --dart-define-from-file=dart_defines.local.json
```

Le script PowerShell `run.ps1` applique également cette configuration.

## Tests

Tests unitaires et widgets :

```powershell
flutter test
```

La suite contient actuellement 20 tests : 15 tests unitaires et 5 tests widgets.

Tests d'intégration :

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_flow_test.dart -d chrome
```

Cette commande nécessite ChromeDriver sur le port `4444`. Les tests couvrent le démarrage de l'application et la validation du formulaire de connexion.

## Performance et structure

- Les listes utilisent `ListView.builder` pour charger les éléments à la demande.
- Les affiches utilisent des dimensions de cache adaptées à leur taille d'affichage.
- Les widgets statiques utilisent `const` lorsque cela est compatible avec la localisation.
- Les dépendances suivent la règle `presentation -> domain <- data`.

```text
lib/
├── core/                 Services transversaux, erreurs, stockage et localisation
├── features/auth/       Authentification et session
├── features/home/       Navigation principale
├── features/movies/     Films, cache et écrans de détail
├── injection.dart       Composition des dépendances
└── main.dart            Point d'entrée
```
