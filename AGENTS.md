# Medicail - AI agent guide

## Locked stack

- **UI**: Flutter, pages in `lib/pages/`, widgets in `lib/widget/`
- **State**: `flutter_bloc` in `lib/features/*/presentation/`
- **DI**: `get_it` + `injectable`
- **Navigation**: `go_router` (`lib/core/router/`)
- **Network**: `dio` via `ApiClient` (`lib/core/network/`)
- **Local STT**: `AudioCaptureService` (`lib/core/audio/`)

## Widget workflow

1. Check whether a component exists in `lib/widget/`
2. If not, create it (button, input, checkbox, etc.)
3. Use it in pages; do not duplicate raw Material widgets

## Useful commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
```

## Security

Anonymize voice text (`AnonymizationHelper`) before any API request.
