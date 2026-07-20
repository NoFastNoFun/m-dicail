import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/note_template/presentation/note_template_bloc.dart';
import 'package:medicail/features/note_template/presentation/note_template_event.dart';
import 'package:medicail/features/note_template/presentation/note_template_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockNoteTemplateRepository extends Mock implements NoteTemplateRepository {}

void main() {
  late _MockNoteTemplateRepository repository;
  late NoteTemplateBloc bloc;

  final builtInTemplate = NoteTemplate(
    id: 'builtin_test',
    pathologyKey: 'ankle_sprain',
    name: 'Entorse de cheville',
    source: NoteTemplateSource.builtIn,
    sections: const [
      NoteSection(
        id: 'subjective',
        kind: NoteSectionKind.subjective,
        title: 'Subjectif',
        prompt: '- Motif :',
        order: 0,
      ),
    ],
  );

  setUp(() {
    repository = _MockNoteTemplateRepository();
    bloc = NoteTemplateBloc(repository);
    registerFallbackValue(builtInTemplate);
  });

  tearDown(() => bloc.close());

  blocTest<NoteTemplateBloc, NoteTemplateState>(
    'loads built-in and user templates',
    build: () {
      when(() => repository.getBuiltInTemplates())
          .thenAnswer((_) async => [builtInTemplate]);
      when(() => repository.getUserVariants()).thenAnswer((_) async => []);
      return bloc;
    },
    act: (bloc) => bloc.add(const NoteTemplatesRequested()),
    expect: () => [
      const NoteTemplateLoading(),
      NoteTemplateLoaded(
        builtInTemplates: [builtInTemplate],
        userVariants: const [],
      ),
    ],
    verify: (_) {
      verify(() => repository.getBuiltInTemplates()).called(1);
      verify(() => repository.getUserVariants()).called(1);
    },
  );

  blocTest<NoteTemplateBloc, NoteTemplateState>(
    'saves user variant',
    build: () {
      when(() => repository.saveVariant(any())).thenAnswer((invocation) async {
        return invocation.positionalArguments.first as NoteTemplate;
      });
      when(() => repository.getBuiltInTemplates())
          .thenAnswer((_) async => [builtInTemplate]);
      when(() => repository.getUserVariants()).thenAnswer((_) async => []);
      return bloc;
    },
    act: (bloc) {
      bloc.add(
        NoteTemplateSaveVariantRequested(
          builtInTemplate.copyWith(
            id: 'variant_1',
            source: NoteTemplateSource.userVariant,
          ),
        ),
      );
    },
    expect: () => [
      isA<NoteTemplateActionSuccess>(),
    ],
  );

  blocTest<NoteTemplateBloc, NoteTemplateState>(
    'prevents deleting built-in templates via repository error',
    build: () {
      when(() => repository.deleteVariant('builtin_test'))
          .thenThrow(StateError('Built-in templates cannot be deleted.'));
      return bloc;
    },
    act: (bloc) => bloc.add(const NoteTemplateDeleteRequested('builtin_test')),
    expect: () => [
      isA<NoteTemplateFailure>(),
    ],
  );
}
