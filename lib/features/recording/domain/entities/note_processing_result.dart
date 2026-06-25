import 'package:equatable/equatable.dart';

class NoteProcessingResult extends Equatable {
  const NoteProcessingResult({
    required this.sessionId,
    required this.processedText,
  });

  final String sessionId;
  final String processedText;

  factory NoteProcessingResult.fromJson(Map<String, dynamic> json) {
    return NoteProcessingResult(
      sessionId: json['session_id'] as String? ?? '',
      processedText: (json['processed_text'] ??
              json['anonymized_text'] ??
              json['raw_text'] ??
              json['text']) as String? ??
          '',
    );
  }

  @override
  List<Object?> get props => [sessionId, processedText];
}
