import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/note_template/domain/repositories/note_template_repository.dart';
import 'package:medicail/features/note_template/presentation/note_template_bloc.dart';
import 'package:medicail/features/note_template/presentation/note_template_event.dart';
import 'package:medicail/features/note_template/presentation/note_template_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/templates/app_template_section_editor.dart';

class TemplateEditorPage extends StatelessWidget {
  const TemplateEditorPage({
    super.key,
    required this.templateId,
    this.initialTemplate,
    this.isCreating = false,
  });

  final String templateId;
  final NoteTemplate? initialTemplate;
  final bool isCreating;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NoteTemplateBloc>(),
      child: _TemplateEditorView(
        templateId: templateId,
        initialTemplate: initialTemplate,
        isCreating: isCreating,
      ),
    );
  }
}

class _TemplateEditorView extends StatefulWidget {
  const _TemplateEditorView({
    required this.templateId,
    this.initialTemplate,
    this.isCreating = false,
  });

  final String templateId;
  final NoteTemplate? initialTemplate;
  final bool isCreating;

  @override
  State<_TemplateEditorView> createState() => _TemplateEditorViewState();
}

class _TemplateEditorViewState extends State<_TemplateEditorView> {
  NoteTemplate? _originalTemplate;
  List<NoteSection> _sections = const [];
  late final TextEditingController _nameController;
  bool _isLoading = true;
  String? _errorMessage;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    if (widget.isCreating) {
      final draft = _createDraftTemplate();
      _originalTemplate = draft;
      _sections = List<NoteSection>.from(draft.orderedSections);
      _nameController.text = draft.name;
      _isLoading = false;
      return;
    }

    final initialTemplate = widget.initialTemplate;
    if (initialTemplate != null) {
      _originalTemplate = initialTemplate;
      _sections = List<NoteSection>.from(initialTemplate.orderedSections);
      _nameController.text = initialTemplate.name;
      _isLoading = false;
      return;
    }
    _loadTemplate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  NoteTemplate _createDraftTemplate() {
    final id = 'custom_${DateTime.now().toUtc().microsecondsSinceEpoch}';
    return NoteTemplate(
      id: id,
      pathologyKey: 'custom_$id',
      name: '',
      source: NoteTemplateSource.userVariant,
      sections: const [
        NoteSection(
          id: 'subjective',
          kind: NoteSectionKind.subjective,
          title: 'Subjectif',
          prompt: '',
          order: 0,
        ),
        NoteSection(
          id: 'objective',
          kind: NoteSectionKind.objective,
          title: 'Objectif',
          prompt: '',
          order: 1,
        ),
        NoteSection(
          id: 'assessment',
          kind: NoteSectionKind.assessment,
          title: 'Evaluation',
          prompt: '',
          order: 2,
        ),
        NoteSection(
          id: 'plan',
          kind: NoteSectionKind.plan,
          title: 'Plan',
          prompt: '',
          order: 3,
        ),
      ],
    );
  }

  Future<void> _loadTemplate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final template =
          await getIt<NoteTemplateRepository>().getById(widget.templateId);
      if (!mounted) {
        return;
      }
      if (template == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'not_found';
        });
        return;
      }

      setState(() {
        _originalTemplate = template;
        _sections = List<NoteSection>.from(template.orderedSections);
        _nameController.text = template.name;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _resetFromParent() async {
    final template = _originalTemplate;
    if (template == null || template.parentTemplateId == null) {
      return;
    }

    final parent =
        await getIt<NoteTemplateRepository>().getById(template.parentTemplateId!);
    if (!mounted || parent == null) {
      return;
    }

    setState(() {
      _sections = List<NoteSection>.from(parent.orderedSections);
    });
  }

  void _updateSection(int index, NoteSection section) {
    setState(() {
      _sections = [
        for (var i = 0; i < _sections.length; i++)
          if (i == index) section else _sections[i],
      ];
    });
  }

  void _addCustomSection() {
    final nextOrder = _sections.isEmpty
        ? 0
        : _sections.map((section) => section.order).reduce(
              (value, element) => value > element ? value : element,
            ) +
            1;

    setState(() {
      _sections = [
        ..._sections,
        NoteSection(
          id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
          kind: NoteSectionKind.custom,
          title: '',
          prompt: '- ',
          order: nextOrder,
        ),
      ];
    });
  }

  void _removeCustomSection(int index) {
    final section = _sections[index];
    if (section.kind != NoteSectionKind.custom) {
      return;
    }

    setState(() {
      _sections = [
        for (var i = 0; i < _sections.length; i++)
          if (i != index) _sections[i],
      ];
    });
  }

  String _slugify(String name) {
    final cleaned = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (cleaned.isEmpty) {
      return 'custom_${DateTime.now().toUtc().microsecondsSinceEpoch}';
    }
    return cleaned;
  }

  NoteTemplate _buildEditedTemplate({required String name}) {
    final template = _originalTemplate!;
    return template.copyWith(
      name: name,
      pathologyKey: template.parentTemplateId == null
          ? _slugify(name)
          : template.pathologyKey,
      sections: _sections,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _save(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final template = _originalTemplate;
    if (template == null) {
      return;
    }

    final name = _nameController.text.trim();
    if (!template.isBuiltIn && name.isEmpty) {
      setState(() => _nameError = l10n.templateNameRequired);
      return;
    }
    setState(() => _nameError = null);

    final bloc = context.read<NoteTemplateBloc>();
    if (template.isBuiltIn) {
      final variant = NoteTemplate(
        id: 'variant_${DateTime.now().toUtc().microsecondsSinceEpoch}',
        pathologyKey: template.pathologyKey,
        name: name.isEmpty
            ? '${template.name} (${l10n.templatesVariantBadge})'
            : name,
        sections: _sections,
        source: NoteTemplateSource.userVariant,
        parentTemplateId: template.id,
        updatedAt: DateTime.now(),
      );
      bloc.add(NoteTemplateSaveVariantRequested(variant));
      return;
    }

    bloc.add(NoteTemplateSaveVariantRequested(_buildEditedTemplate(name: name)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<NoteTemplateBloc, NoteTemplateState>(
      listener: (context, state) {
        if (state is NoteTemplateActionSuccess) {
          AppToast.showSuccess(context, l10n.templateSaved);
          if (widget.isCreating ||
              (_originalTemplate?.isBuiltIn == true &&
                  state.savedTemplateId != null)) {
            context.pop();
          }
        }
        if (state is NoteTemplateFailure) {
          AppToast.showError(context, state.message);
        }
      },
      child: AppScaffold(
        title: widget.isCreating
            ? l10n.templateCreateTitle
            : (_originalTemplate?.name.isNotEmpty == true
                ? _originalTemplate!.name
                : l10n.templateEditorTitle),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: AppText(
          l10n.templateNotFound,
          variant: AppTextVariant.body,
        ),
      );
    }

    final template = _originalTemplate!;
    final isBuiltIn = template.isBuiltIn;
    final canReset = !isBuiltIn && template.parentTemplateId != null;
    final showNameField = !isBuiltIn || widget.isCreating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: MainShellScope.scrollPaddingOf(context),
            children: [
              if (showNameField) ...[
                AppInput(
                  variant: AppInputVariant.text,
                  label: l10n.templateNameLabel,
                  controller: _nameController,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              for (var index = 0; index < _sections.length; index++)
                AppTemplateSectionEditor(
                  section: _sections[index],
                  titleLabel: l10n.templateSectionTitleLabel,
                  promptLabel: l10n.templateSectionPromptLabel,
                  canDelete: _sections[index].kind == NoteSectionKind.custom,
                  onDelete: () => _removeCustomSection(index),
                  onTitleChanged: (value) => _updateSection(
                    index,
                    _sections[index].copyWith(title: value),
                  ),
                  onPromptChanged: (value) => _updateSection(
                    index,
                    _sections[index].copyWith(prompt: value),
                  ),
                ),
              AppButton(
                label: l10n.templateAddSection,
                style: AppButtonStyle.secondary,
                layout: AppButtonLayout.textWithIcon,
                icon: Icons.add,
                onPressed: _addCustomSection,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: widget.isCreating
              ? l10n.templateSaveCreate
              : (isBuiltIn ? l10n.templateSaveAsVariant : l10n.templateUpdate),
          onPressed: () => _save(context),
        ),
        if (canReset) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.templateReset,
            style: AppButtonStyle.secondary,
            onPressed: _resetFromParent,
          ),
        ],
      ],
    );
  }
}
