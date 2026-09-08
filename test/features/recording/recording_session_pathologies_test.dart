import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/recording/data/models/recording_session_model.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/session_pathology.dart';

void main() {
  test('round-trips pathologies in JSON', () {
    final model = RecordingSessionModel(
      id: 'recording_1',
      startedAt: DateTime.utc(2026, 1, 1),
      status: RecordingSessionStatus.completed,
      templateId: 'tpl_1',
      templateName: 'Lombalgie',
      pathologies: const [
        SessionPathology(
          id: 'path_low_back_pain',
          name: 'Lombalgie',
          templateId: 'tpl_1',
        ),
        SessionPathology(
          id: 'path_neck_pain',
          name: 'Cervicalgie',
          templateId: 'tpl_2',
        ),
      ],
    );

    final restored = RecordingSessionModel.fromJson(model.toJson());

    expect(restored.pathologies, hasLength(2));
    expect(restored.pathologies.first.id, 'path_low_back_pain');
    expect(restored.pathologies.last.name, 'Cervicalgie');
    expect(restored.pathologyNames, ['Lombalgie', 'Cervicalgie']);
  });

  test('pathologyNames falls back to legacy templateName', () {
    final model = RecordingSessionModel.fromJson({
      'id': 'recording_legacy',
      'started_at': '2026-01-01T00:00:00.000Z',
      'status': 'completed',
      'template_id': 'tpl_legacy',
      'template_name': 'Entorse de cheville',
    });

    expect(model.pathologies, isEmpty);
    expect(model.pathologyNames, ['Entorse de cheville']);
    expect(model.hasPathology, isTrue);
  });

  test('empty pathologies and templateName yield no names', () {
    final model = RecordingSessionModel(
      id: 'recording_empty',
      startedAt: DateTime.utc(2026, 1, 1),
      status: RecordingSessionStatus.draft,
    );

    expect(model.pathologyNames, isEmpty);
    expect(model.hasPathology, isFalse);
  });
}
