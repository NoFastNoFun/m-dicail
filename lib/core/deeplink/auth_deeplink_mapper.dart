import 'package:medicail/core/router/app_routes.dart';

/// Maps an incoming OS / email URI into a go_router location.
///
/// Supports custom scheme (`medicail://reset-password?token=…`) and
/// HTTPS bounce URLs (`https://host/reset-password?token=…`).
String? mapIncomingAuthUri(Uri uri) {
  final path = _resolveAuthPath(uri);
  if (path == null) return null;

  final token = uri.queryParameters['token'];
  if (token == null || token.isEmpty) {
    return path;
  }
  return Uri(path: path, queryParameters: {'token': token}).toString();
}

String? _resolveAuthPath(Uri uri) {
  final scheme = uri.scheme.toLowerCase();

  if (scheme == 'medicail') {
    final host = uri.host.toLowerCase();
    if (host == 'reset-password') return AppRoutes.resetPassword;
    if (host == 'recovery') return AppRoutes.recovery;

    for (final segment in uri.pathSegments) {
      final value = segment.toLowerCase();
      if (value == 'reset-password') return AppRoutes.resetPassword;
      if (value == 'recovery') return AppRoutes.recovery;
    }
    return null;
  }

  if (scheme == 'https' || scheme == 'http') {
    final path = uri.path.toLowerCase();
    if (path == AppRoutes.resetPassword ||
        path.startsWith('${AppRoutes.resetPassword}/')) {
      return AppRoutes.resetPassword;
    }
    if (path == AppRoutes.recovery || path.startsWith('${AppRoutes.recovery}/')) {
      return AppRoutes.recovery;
    }
  }

  return null;
}
