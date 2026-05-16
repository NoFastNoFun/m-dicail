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