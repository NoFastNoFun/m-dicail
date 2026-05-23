import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/templates/domain/entities/custom_template_variant.dart';
import 'package:medicail/features/templates/domain/entities/soap_template.dart';
import 'package:medicail/features/templates/domain/entities/template_list_item.dart';
import 'package:medicail/features/templates/domain/repositories/template_repository.dart';
import 'package:medicail/features/templates/presentation/template_bloc.dart';
import 'package:medicail/features/templates/presentation/template_event.dart';
import 'package:medicail/features/templates/presentation/template_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      CustomTemplateVariant(
        id: 'fallback',
        displayName: 'fallback',
        subjective: '',
        objective: '',
        assessment: '',
        plan: '',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
  });

  late _MockTemplateRepository repository;
  late TemplateBloc bloc;

  final builtin = SoapTemplate(
    id: 'template_lombalgie',
    pathologyName: 'Lombalgie',
    subjectiveDefault: 'S',
    objectiveDefault: 'O',
    assessmentDefault: 'A',
    planDefault: 'P',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  final items = [
    TemplateListItem(
      id: builtin.id,
      displayName: builtin.pathologyName,
      type: TemplateItemType.builtin,
      soapNote: builtin.toSoapNote(),
    ),
  ];

  setUp(() {
    repository = _MockTemplateRepository();
    when(() => repository.ensureSeeded()).thenAnswer((_) async {});
    when(() => repository.getAllItems(query: any(named: 'query')))
        .thenAnswer((_) async => items);
    when(() => repository.findVariantByDisplayName(any()))
        .thenAnswer((_) async => null);
    when(() => repository.saveVariant(any())).thenAnswer((_) async {});
    bloc = TemplateBloc(repository);
  });

  blocTest<TemplateBloc, TemplateState>(
    'emits loaded items on load',
    build: () => bloc,
    act: (b) => b.add(const TemplatesLoadRequested()),
    expect: () => [
      const TemplateLoading(),
      isA<TemplateLoaded>()
          .having((s) => s.items.length, 'items', 1)
          .having((s) => s.query, 'query', ''),
    ],
  );

  blocTest<TemplateBloc, TemplateState>(
    'filters items on search query',
    build: () => bloc,
    seed: () => const TemplateLoaded(items: [], query: ''),
    act: (b) => b.add(const TemplateSearchQueryChanged('lomb')),
    wait: const Duration(milliseconds: 350),
    expect: () => [
      isA<TemplateLoaded>().having((s) => s.query, 'query', 'lomb'),
    ],
    verify: (_) {
      verify(() => repository.getAllItems(query: 'lomb')).called(1);
    },
  );

  blocTest<TemplateBloc, TemplateState>(
    'sets selected note on template selected',
    build: () => bloc,
    seed: () => TemplateLoaded(items: items),
    act: (b) => b.add(TemplateSelected(builtin.id)),
    expect: () => [
      isA<TemplateLoaded>()
          .having((s) => s.selectedNote?.subjective, 'subjective', 'S'),
    ],
  );

  blocTest<TemplateBloc, TemplateState>(
    'emits pending duplicate when name exists',
    build: () {
      when(() => repository.findVariantByDisplayName('Ma variante'))
          .thenAnswer(
        (_) async => CustomTemplateVariant(
          id: 'variant_existing',
          displayName: 'Ma variante',
          subjective: '',
          objective: '',
          assessment: '',
          plan: '',
          createdAt: DateTime.now(),
        ),
      );
      return bloc;
    },
    seed: () => TemplateLoaded(items: items),
    act: (b) => b.add(
      const VariantSaveRequested(
        displayName: 'Ma variante',
        soapNote: SoapNote(subjective: 'x'),
      ),
    ),
    expect: () => [
      isA<TemplateLoaded>().having(
        (s) => s.pendingDuplicateVariantId,
        'duplicate',
        'variant_existing',
      ),
    ],
  );

  blocTest<TemplateBloc, TemplateState>(
    'saves variant and reloads on success',
    build: () => bloc,
    seed: () => TemplateLoaded(items: items),
    act: (b) => b.add(
      const VariantSaveRequested(
        displayName: 'Nouvelle variante',
        soapNote: SoapNote(subjective: 'Contenu'),
      ),
    ),
    expect: () => [
      const TemplateSavingSuccess(),
      isA<TemplateLoaded>(),
    ],
    verify: (_) {
      verify(() => repository.saveVariant(any())).called(1);
    },
  );
}
