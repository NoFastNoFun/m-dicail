import 'package:equatable/equatable.dart';

sealed class VoiceCaptureState extends Equatable {
  const VoiceCaptureState();

  @override
  List<Object?> get props => [];
}

final class VoiceCaptureInitial extends VoiceCaptureState {
  const VoiceCaptureInitial();
}

final class VoiceCaptureReady extends VoiceCaptureState {
  const VoiceCaptureReady({this.transcript = ''});

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

final class VoiceCaptureConsultationFinished extends VoiceCaptureState {
  const VoiceCaptureConsultationFinished({this.transcript = ''});

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

final class RecordingInProgress extends VoiceCaptureState {
  const RecordingInProgress({required this.transcript});

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

final class ListeningPaused extends VoiceCaptureState {
  const ListeningPaused({required this.transcript});

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

final class VoiceCaptureFailure extends VoiceCaptureState {
  const VoiceCaptureFailure(this.message, {this.transcript = ''});

  final String message;
  final String transcript;

  @override
  List<Object?> get props => [message, transcript];
}
