import 'package:equatable/equatable.dart';

sealed class TutorialEvent extends Equatable {
  const TutorialEvent();

  @override
  List<Object?> get props => [];
}

final class TutorialCheckRequested extends TutorialEvent {
  const TutorialCheckRequested();
}

final class TutorialStartRequested extends TutorialEvent {
  const TutorialStartRequested();
}

final class TutorialStepCompleted extends TutorialEvent {
  const TutorialStepCompleted(this.completedStep);
  final int completedStep;

  @override
  List<Object?> get props => [completedStep];
}

final class TutorialSkipRequested extends TutorialEvent {
  const TutorialSkipRequested();
}
