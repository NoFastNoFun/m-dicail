# Medicail

Application open source d'assistance mains libres pour les kinesitherapeutes.
L'objectif est de proposer un assistant clinique local-first, utilisable pendant
une seance sans casser le flux avec le patient.

## Vision du projet

Medicail permet de:

- acceder rapidement a des recommandations d'exercices;
- consulter des syntheses scientifiques (notamment basees sur PubMed);
- capturer des notes vocales structurees pendant la seance;
- rester operationnel hors ligne autant que possible.

Le projet privilegie une architecture stable et fiable en local avant toute
dependance a des services IA distants.

## Stack principale

- Flutter (mobile, desktop, web)
- Dart
- Approche local-first

## Prerequis

Avant de lancer le projet:

1. Installer Flutter SDK (canal stable recommande)
2. Installer un SDK compatible (Android Studio/Xcode selon plateforme)
3. Verifier l'environnement:

```bash
flutter doctor
```

## Installation

```bash
flutter pub get
```

## Lancer l'application

Lister les devices disponibles:

```bash
flutter devices
```

Executer en mode debug:

```bash
flutter run
```

Executer sur cible specifique:

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d android
```

## Mode hors ligne (invite)

L'application fonctionne sans compte. Au premier lancement, l'ecran de connexion
propose **Continuer sans compte** : les patients, sessions et notes SOAP sont
alors stockes localement de maniere chiffree (`flutter_secure_storage`).

Les lancements suivants ouvrent directement l'accueil. La connexion reste
optionnelle pour synchroniser avec le backend.

Un mode de test supplementaire permet de se connecter avec les identifiants
`admin` / `admin` sans backend. Il est active via un flag de compilation
`--dart-define`.

### Depuis le terminal

```bash
flutter run --dart-define=ENABLE_MOCK_ADMIN=true
```

### Depuis VS Code

Le fichier `.vscode/launch.json` contient deux configurations pre-configurees :

- **Medicail (mock admin)** : mode hors ligne avec le flag active
- **Medicail** : mode standard (connexion au backend)

Selectionnez la configuration souhaitee dans le menu de lancement de VS Code
(F5 ou barre de debug), puis lancez.

### Variables d'environnement disponibles

| Variable | Type | Default | Description |
|---|---|---|---|
| `ENABLE_MOCK_ADMIN` | `bool` | `false` | Active la connexion `admin`/`admin` |
| `API_BASE_URL` | `String` | `http://localhost:8000` | URL de base de l'API |

Exemple combinant les deux :

```bash
flutter run --dart-define=ENABLE_MOCK_ADMIN=true --dart-define=API_BASE_URL=https://api.staging.example.com
```

## Commandes utiles (qualite)

Analyser le code:

```bash
flutter analyze
```

Formater le code:

```bash
dart format .
```

Executer les tests:

```bash
flutter test
```

## Build

Exemples de build:

```bash
flutter build apk
flutter build web
flutter build windows
```

### APK Android allégés par appareil

Par défaut, `flutter build apk` produit un **APK universel** qui embarque les
bibliothèques natives de toutes les architectures (arm64, arm32, x86_64). Le
fichier est plus lourd, mais compatible avec la plupart des appareils.

Pour réduire la taille, préférez l'une des approches suivantes.

#### 1. APK séparés par architecture (recommandé pour installation directe)

Génère un APK par type de processeur. Chaque utilisateur installe uniquement
celui qui correspond à son téléphone.

```bash
flutter build apk --release --split-per-abi
```

Fichiers produits dans `build/app/outputs/flutter-apk/` :

| Fichier | Appareils typiques |
|---|---|
| `app-arm64-v8a-release.apk` | Smartphones récents (2017+) |
| `app-armeabi-v7a-release.apk` | Anciens appareils 32 bits |
| `app-x86_64-release.apk` | Émulateurs / quelques tablettes |

La plupart des téléphones actuels utilisent **`arm64-v8a`**.

#### 2. Cibler une seule architecture

Utile si vous connaissez l'appareil cible (démo, test interne, flotte homogène).

```bash
# Smartphones Android récents
flutter build apk --release --target-platform android-arm64

# Appareils 32 bits
flutter build apk --release --target-platform android-arm
```

#### 3. App Bundle pour Google Play (recommandé en production)

Pour une publication sur le Play Store, utilisez un **AAB** : Google génère et
distribue automatiquement l'APK adapté à chaque appareil.

```bash
flutter build appbundle --release
```

Le fichier est produit dans `build/app/outputs/bundle/release/`.

> **Note** : la configuration de signature release doit être définie dans
> `android/app/build.gradle.kts` avant une publication en production (actuellement
> le build release utilise encore la clé debug).

## Structure du projet

```text
lib/
  app/                 # MaterialApp, bootstrap
  core/                # DI, reseau, router, i18n, audio, utils
  features/            # voice_capture, consultation (BLoC + domain/data)
  pages/               # Ecrans routes (home, record)
  widget/              # Design system (AppButton, AppTextField, ...)
test/
```

Regenerer le code DI apres modification des injections:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Roadmap technique (court terme)

- stabiliser le coeur local-first;
- fiabiliser la reconnaissance vocale et la prise de notes;
- renforcer la qualite (tests, analyse statique, architecture modulaire);
- preparer ensuite l'integration de services IA distants, seulement si le socle
  local est robuste.

## Contribution

1. Creer une branche:
   `git checkout -b feature/ma-feature`
2. Commiter avec des messages clairs
3. Ouvrir une Pull Request

## Licence

A definir.