# MovieApp — Flutter + API réelle (Clean Architecture)

Application Flutter connectée à deux APIs REST réelles, avec authentification
JWT, cache local et mode hors-ligne, construite en Clean Architecture
(`data` / `domain` / `presentation`) organisée en **Feature-First**.

## Sommaire

- [APIs utilisées](#apis-utilisées)
- [Architecture](#architecture)
- [Configuration du projet](#configuration-du-projet)
- [Lancer l'app](#lancer-lapp)
- [Lancer les tests](#lancer-les-tests)
- [Détail des fonctionnalités obligatoires](#détail-des-fonctionnalités-obligatoires)
- [Limites connues et pistes d'amélioration](#limites-connues-et-pistes-damélioration)

---

## APIs utilisées

| API                                                      | Rôle dans l'app                                                                                          | Auth requise                                            |
| -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| **[TMDB](https://www.themoviedb.org/documentation/api)** | Données métier : films "à l'affiche", "populaires", "mieux notés", détail d'un film                      | Clé API gratuite (`api_key` en query param)             |
| **[ReqRes](https://reqres.in)**                          | Démo du flux d'authentification (`/login`, `/register`) — API factice qui renvoie un vrai JWT-like token | Clé API gratuite (`x-api-key`, obligatoire depuis 2025) |

**Pourquoi deux APIs ?** TMDB n'a pas de système de comptes utilisateurs
exploitable pour un flow login/register classique. ReqRes sert donc
uniquement à démontrer proprement le pattern JWT + intercepteur + refresh.
En production, tu remplacerais `AuthRemoteDataSource` par un appel à _ton_
backend — **aucune autre couche du projet ne change** : c'est tout l'intérêt
du repository pattern.

Comptes de test ReqRes (seuls ceux-ci fonctionnent, l'API est une fixture) :
`eve.holt@reqres.in` / `cityslicka` pour le login. Pour `/register`,
utilise un des emails listés sur https://reqres.in/llm.txt (fixture users).

## Architecture

```
lib/
├── core/                        # Transverse, ne dépend d'aucune feature
│   ├── constants/                → URLs, clés API
│   ├── error/                    → exceptions (data) + Failures (domain)
│   ├── network/                  → Dio, intercepteur JWT + refresh, connectivité
│   ├── storage/                  → Hive (cache), secure storage (tokens)
│   └── utils/                    → Either<L, R> maison
│
├── features/
│   ├── auth/
│   │   ├── domain/               → entités + contrat repository (abstrait)
│   │   ├── data/                 → models, datasources (remote/local), repository impl
│   │   └── presentation/         → provider (état) + écrans login/register
│   │
│   ├── movies/
│   │   ├── domain/                → Movie, MovieRepository (abstrait)
│   │   ├── data/                  → MovieModel, remote (TMDB) + local (Hive), repository impl
│   │   └── presentation/          → provider générique + 3 écrans + détail
│   │
│   └── home/presentation/         → navigation par onglets entre les 3 écrans
│
├── injection.dart                # Composition root (câblage manuel des dépendances)
└── main.dart
```

**Règle de dépendance** : `presentation` → `domain` ← `data`. Le `domain`
ne connaît ni Dio, ni Hive, ni ReqRes/TMDB — uniquement des interfaces
(`AuthRepository`, `MovieRepository`) et des entités pures. C'est ce qui
rend la couche `data` interchangeable et testable en isolation.

**Repository pattern** : chaque repository (`AuthRepositoryImpl`,
`MovieRepositoryImpl`) orchestre un datasource distant (API) et un
datasource local (cache), et c'est lui — pas l'UI, pas les datasources —
qui décide "j'appelle le réseau" vs "je sers le cache" (voir
`MovieRepositoryImpl.getMovies`).

## Configuration du projet

1. **Clé TMDB** : crée un compte gratuit sur
   https://www.themoviedb.org/settings/api et récupère ta clé "API Key (v3 auth)".
2. **Clé ReqRes** : crée un compte gratuit sur https://app.reqres.in et
   récupère ta clé API.
3. Ne mets **jamais** ces clés en dur dans `api_constants.dart` si le repo
   est public. Copie `dart_defines.example.json` vers
   `dart_defines.local.json` et remplace les valeurs par tes clés. Le fichier
   local est ignoré par Git.

```bash
cp dart_defines.example.json dart_defines.local.json
```

Ensuite, lance l'app avec `F5` dans VS Code, `./run.sh` sur macOS/Linux ou
`./run.ps1` dans PowerShell. Ces lanceurs utilisent
`--dart-define-from-file=dart_defines.local.json`.

## Lancer l'app

```bash
flutter pub get
flutter run --dart-define-from-file=dart_defines.local.json
```

# MovieApp

Application Flutter de découverte de films, construite avec une architecture
Clean et une organisation **Feature-First**. Elle utilise TMDB pour les données
de films et ReqRes pour le flux d'authentification.

## Fonctionnalités

- Connexion, inscription et déconnexion
- Conservation sécurisée des tokens avec `flutter_secure_storage`
- Liste des films à l'affiche, populaires et les mieux notés
- Consultation du détail d'un film
- Cache local avec Hive
- Fonctionnement hors ligne avec repli automatique sur le cache
- Rafraîchissement du token après une réponse HTTP `401`
- Gestion des états de chargement et des erreurs réseau

## APIs

| API                                                  | Utilisation                       |
| ---------------------------------------------------- | --------------------------------- |
| [TMDB](https://www.themoviedb.org/documentation/api) | Films, détails et images          |
| [ReqRes](https://reqres.in)                          | Authentification de démonstration |

ReqRes est une API de démonstration. Le compte de test pour la connexion est
`eve.holt@reqres.in` avec le mot de passe `cityslicka`. Les règles de ReqRes
s'appliquent également à l'inscription.

## Prérequis

- Flutter avec le SDK Dart compatible avec `pubspec.yaml`
- Une clé API TMDB
- Une clé API ReqRes

## Configuration

Copier le fichier d'exemple, puis renseigner les deux clés :

```bash
cp dart_defines.example.json dart_defines.local.json
```

Le fichier `dart_defines.local.json` ne doit pas être versionné. Les clés sont
lues par `lib/core/constants/api_constants.dart` via `--dart-define`.

## Installation et lancement

```bash
flutter pub get
flutter run --dart-define-from-file=dart_defines.local.json
```

Sous PowerShell, le script `run.ps1` lance l'application dans Chrome. Sous
macOS ou Linux, `run.sh` lance l'application sur la cible Flutter disponible.

## Tests

```bash
flutter test
```

Les tests couvrent les repositories, les datasources d'authentification et
l'intercepteur réseau :

- connexion, inscription, déconnexion et état de session ;
- gestion des erreurs d'authentification et de réseau ;
- récupération des films en ligne ;
- utilisation du cache hors ligne ou après une erreur serveur ;
- ajout du token Bearer et rejeu après un `401`.

## Architecture

```text
lib/
├── core/
│   ├── constants/       Configuration des APIs
│   ├── error/           Exceptions et failures
│   ├── network/         Dio, intercepteur et connectivité
│   ├── storage/         Hive et stockage sécurisé
│   └── utils/           Types utilitaires
├── features/
│   ├── auth/            Authentification et gestion de session
│   ├── home/            Navigation principale
│   └── movies/          Films, cache et écrans de détail
├── injection.dart       Construction des dépendances
└── main.dart            Point d'entrée de l'application
```

Chaque fonctionnalité est organisée en trois couches :

- `domain` contient les entités et les contrats des repositories ;
- `data` contient les modèles, datasources et implémentations ;
- `presentation` contient les providers et les écrans.

La couche `domain` reste indépendante de Dio, Hive et des APIs externes. Les
repositories choisissent entre les données distantes et le cache local, tandis
que la présentation observe leur état via Provider.

## Notes techniques

- ReqRes ne fournit pas de véritable endpoint de renouvellement de token. Le
  refresh utilisé par cette application est donc une simulation adaptée à la
  démonstration de l'intercepteur.
- TMDB utilise sa clé API pour les appels métier. Le token Bearer de la session
  ReqRes sert uniquement à illustrer le mécanisme d'authentification réseau.
- Les listes chargent la première page de résultats TMDB.
