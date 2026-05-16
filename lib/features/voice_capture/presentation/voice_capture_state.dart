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

final class RecordingInProgress extends VoiceCaptureState {
  const RecordingInProgress({required this.transcript});

  final String transcript;

  @override
  List<Object?> get props => [transcript];
}

final class VoiceCaptureFailure extends VoiceCaptureState {
  const VoiceCaptureFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
