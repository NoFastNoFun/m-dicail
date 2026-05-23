import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

sealed class VoiceCaptureState extends Equatable {
  const VoiceCaptureState();

  @override
  List<Object?> get props => [];
}

final class VoiceCaptureInitial extends VoiceCaptureState {
  const VoiceCaptureInitial();
}

final class VoiceCaptureReady extends VoiceCaptureState {
  const VoiceCaptureReady({
    this.transcript = '',
    this.activeSessionId,
    this.activeSoapNote,
  });

  final String transcript;
  final String? activeSessionId;
  final SoapNote? activeSoapNote;

  @override
  List<Object?> get props => [transcript, activeSessionId, activeSoapNote];
}

final class VoiceCaptureConsultationFinished extends VoiceCaptureState {
  const VoiceCaptureConsultationFinished({
    required this.sessionId,
    this.transcript = '',
  });

  final String sessionId;
  final String transcript;

  @override
  List<Object?> get props => [sessionId, transcript];
}

final class RecordingInProgress extends VoiceCaptureState {
  const RecordingInProgress({
    required this.transcript,
    this.activeSessionId,
    this.activeSoapNote,
  });

  final String transcript;
  final String? activeSessionId;
  final SoapNote? activeSoapNote;

  @override
  List<Object?> get props => [transcript, activeSessionId, activeSoapNote];
}

final class ListeningPaused extends VoiceCaptureState {
  const ListeningPaused({
    required this.transcript,
    this.activeSessionId,
    this.activeSoapNote,
  });

  final String transcript;
  final String? activeSessionId;
  final SoapNote? activeSoapNote;

  @override
  List<Object?> get props => [transcript, activeSessionId, activeSoapNote];
}

final class VoiceCaptureFailure extends VoiceCaptureState {
  const VoiceCaptureFailure(
    this.message, {
    this.transcript = '',
    this.activeSessionId,
    this.activeSoapNote,
  });

  final String message;
  final String transcript;
  final String? activeSessionId;
  final SoapNote? activeSoapNote;

  @override
  List<Object?> get props => [message, transcript, activeSessionId, activeSoapNote];
}
