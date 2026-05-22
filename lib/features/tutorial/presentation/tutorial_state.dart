import 'package:equatable/equatable.dart';

sealed class TutorialState extends Equatable {
  const TutorialState();

  @override
  List<Object?> get props => [];
}

final class TutorialInitial extends TutorialState {
  const TutorialInitial();
}

final class TutorialInProgress extends TutorialState {
  const TutorialInProgress(this.currentStep);
  final int currentStep;

  @override
  List<Object?> get props => [currentStep];
}

final class TutorialCompleted extends TutorialState {
  const TutorialCompleted();
}
