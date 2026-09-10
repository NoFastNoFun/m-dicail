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
      // On renomme l'événement pour inclure l'information de l'IA vu que le DTO n'a pas de champ is_ai_generated
      final eventName = isAiGenerated ? 'soap_generation_ux_time_ai' : 'soap_generation_ux_time_standard';

      _dio.post(
        '/telemetry/metrics',
        data: {
          'event': eventName,
          'duration_ms': durationMs,
          'device': Platform.operatingSystem, // 'ios' ou 'android'
          'network_type': 'unknown', // Renseigné par défaut si non disponible côté Flutter
        },
      ).ignore();
    } catch (e) {
      // Les erreurs de télémétrie sont silencieuses pour ne pas impacter l'utilisateur
    }
  }
}
