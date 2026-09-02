import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/tutorial/domain/repositories/tutorial_repository.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';

class _FakeTutorialRepository implements TutorialRepository {
  bool completed = false;
  int? currentStep;

  @override
  Future<void> clearCurrentTutorialStep() async {
    currentStep = null;
  }

  @override
  Future<int?> getCurrentTutorialStep() async => currentStep;

  @override
  Future<bool> hasCompletedTutorial() async => completed;

  @override
  Future<void> resetTutorial() async {
    completed = false;
    currentStep = null;
  }

  @override
  Future<void> setCurrentTutorialStep(int step) async {
    currentStep = step;
  }

  @override
  Future<void> setTutorialCompleted() async {
    completed = true;
    currentStep = null;
  }
}

class _FakeRecordingSessionRepository implements RecordingSessionRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<RecordingSession>> getAll() async => [];

  @override
  Future<RecordingSession?> getById(String id) async => null;

  @override
  Future<List<RecordingSession>> getByPatientId(String patientId) async => [];

  @override
  Future<void> purgeTutorialSessions() async {}

  @override
  Future<RecordingSession> save(RecordingSession session) async => session;
}

void main() {
  late _FakeTutorialRepository repository;
  late TutorialBloc bloc;

  setUp(() {
    repository = _FakeTutorialRepository();
    bloc = TutorialBloc(repository, _FakeRecordingSessionRepository());
  });

  tearDown(() => bloc.close());

  test('starts loading until storage is read', () {
    expect(bloc.state, const TutorialLoading());
  });

  blocTest<TutorialBloc, TutorialState>(
    'does not prompt again after skip is persisted',
    setUp: () => repository.completed = true,
    build: () => bloc,
    act: (bloc) => bloc.add(const TutorialCheckRequested()),
    expect: () => [const TutorialCompleted()],
  );

  blocTest<TutorialBloc, TutorialState>(
    'offers the intro only when tutorial was never started or skipped',
    build: () => bloc,
    act: (bloc) => bloc.add(const TutorialCheckRequested()),
    expect: () => [const TutorialInitial()],
  );

  blocTest<TutorialBloc, TutorialState>(
    'skip persists completion',
    build: () => bloc,
    act: (bloc) => bloc.add(const TutorialSkipRequested()),
    expect: () => [const TutorialCompleted()],
    verify: (_) => expect(repository.completed, isTrue),
  );

  blocTest<TutorialBloc, TutorialState>(
    'resumes an in-progress tutorial instead of prompting',
    setUp: () => repository.currentStep = TutorialFlow.firstStep,
    build: () => bloc,
    act: (bloc) => bloc.add(const TutorialCheckRequested()),
    expect: () => [TutorialInProgress(TutorialFlow.firstStep)],
  );
}
