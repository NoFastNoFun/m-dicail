import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class TelemetryService {
  final Dio _dio;

  TelemetryService(this._dio);

  Future<void> sendSoapGenerationTime({
    required int durationMs,
    required bool isAiGenerated,
  }) async {
    try {
      // Envoi de la métrique en arrière-plan ("fire and forget")
      // L'URL exacte dépendra de la configuration de votre instance Dio
      _dio.post(
        '/api/telemetry/metrics',
        data: {
          'event': 'soap_generation_ux_time',
          'duration_ms': durationMs,
          'is_ai_generated': isAiGenerated,
          'device_os': Platform.operatingSystem,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ).ignore(); // Ne pas attendre la réponse
    } catch (e) {
      // Les erreurs de télémétrie sont silencieuses pour ne pas impacter l'utilisateur
    }
  }
}
