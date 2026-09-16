import 'package:injectable/injectable.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/search/domain/global_search_result.dart';

@lazySingleton
class GlobalSearchService {
  GlobalSearchService(this._patients, this._sessions);

  final PatientRepository _patients;
  final RecordingSessionRepository _sessions;

  Future<GlobalSearchResults> search(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return const GlobalSearchResults();
    }
    final q = query.toLowerCase();

    final matchedPatients = await _patients.getAll(query: query);
    final patientById = <String, Patient>{
      for (final patient in matchedPatients) patient.id: patient,
    };

    final sessionById = <String, RecordingSession>{};

    // Guest / offline: local getAll exposes transcripts & notes.
    for (final session in await _sessions.getAll()) {
      if (_sessionMatches(session, q)) {
        sessionById[session.id] = session;
      }
    }

    // Online: existing patient search + per-patient session lists (no new BE routes).
    for (final patient in matchedPatients.take(25)) {
      final list = await _sessions.getByPatientId(patient.id);
      for (final session in list) {
        if (_sessionMatches(session, q)) {
          sessionById[session.id] = session;
        }
      }
    }

    // When the query hits a patient name but no session text, still surface a
    // few recent sessions for those patients for quick navigation.
    if (matchedPatients.isNotEmpty && sessionById.isEmpty) {
      for (final patient in matchedPatients.take(10)) {
        final list = await _sessions.getByPatientId(patient.id);
        for (final session in list.take(5)) {
          sessionById.putIfAbsent(session.id, () => session);
        }
      }
    }

    for (final session in sessionById.values) {
      final patientId = session.patientId;
      if (patientId == null || patientById.containsKey(patientId)) continue;
      final patient = await _patients.getById(patientId);
      if (patient != null) {
        patientById[patient.id] = patient;
      }
    }

    final patientHits = [
      for (final patient in matchedPatients) GlobalSearchPatientHit(patient),
    ];

    final sessionHits = [
      for (final session in sessionById.values)
        GlobalSearchSessionHit(
          session: session,
          patientName: session.patientId == null
              ? null
              : patientById[session.patientId!]?.displayName,
          snippet: _snippetFor(session, q),
        ),
    ]..sort((a, b) => b.session.startedAt.compareTo(a.session.startedAt));

    return GlobalSearchResults(
      patients: patientHits,
      sessions: sessionHits,
    );
  }

  bool _sessionMatches(RecordingSession session, String q) {
    if (session.transcript.toLowerCase().contains(q)) return true;
    for (final name in session.pathologyNames) {
      if (name.toLowerCase().contains(q)) return true;
    }
    final note = session.soapNote;
    if (note != null && _soapMatches(note, q)) return true;
    return false;
  }

  bool _soapMatches(SoapNote note, String q) {
    return note.subjective.toLowerCase().contains(q) ||
        note.objective.toLowerCase().contains(q) ||
        note.assessment.toLowerCase().contains(q) ||
        note.plan.toLowerCase().contains(q);
  }

  String? _snippetFor(RecordingSession session, String q) {
    final candidates = <String>[
      session.transcript,
      if (session.soapNote != null) ...[
        session.soapNote!.subjective,
        session.soapNote!.objective,
        session.soapNote!.assessment,
        session.soapNote!.plan,
      ],
    ];
    for (final text in candidates) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) continue;
      final lower = trimmed.toLowerCase();
      final index = lower.indexOf(q);
      if (index >= 0) {
        final start = (index - 24).clamp(0, trimmed.length);
        final end = (index + q.length + 48).clamp(0, trimmed.length);
        final slice = trimmed.substring(start, end).trim();
        final prefix = start > 0 ? '…' : '';
        final suffix = end < trimmed.length ? '…' : '';
        return '$prefix$slice$suffix';
      }
      if (trimmed.length <= 120) return trimmed;
      return '${trimmed.substring(0, 120).trim()}…';
    }
    return null;
  }
}
