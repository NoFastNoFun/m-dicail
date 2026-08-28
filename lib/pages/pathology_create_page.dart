import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_domain.dart';
import 'package:medicail/features/pathology/domain/utils/pathology_labels.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class PathologyCreatePage extends StatefulWidget {
  const PathologyCreatePage({
    super.key,
    required this.onCreate,
  });

  final Future<void> Function(String name, PathologyDomain domain) onCreate;

  @override
  State<PathologyCreatePage> createState() => _PathologyCreatePageState();
}

class _PathologyCreatePageState extends State<PathologyCreatePage> {
  final _nameController = TextEditingController();
  PathologyDomain _domain = PathologyDomain.musculoskeletal;
  bool _isSaving = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.templateNameRequired);
      return;
    }

    setState(() {
      _nameError = null;
      _isSaving = true;
    });

    try {
      await widget.onCreate(name, _domain);
      if (!mounted) {
        return;
      }
      AppToast.showSuccess(context, l10n.templateSaved);
      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      AppToast.show(context, message: error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.templateCreateTitle,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppInput(
            variant: AppInputVariant.text,
            label: l10n.templateNameLabel,
            controller: _nameController,
            errorText: _nameError,
            validator: (_) => _nameError,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(l10n.pathologyDomainLabel, variant: AppTextVariant.body),
          const SizedBox(height: AppSpacing.sm),
          ...PathologyDomain.values.map(
            (domain) => RadioListTile<PathologyDomain>(
              value: domain,
              groupValue: _domain,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _domain = value);
                    },
              title: AppText(domain.labelFr(), variant: AppTextVariant.body),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.templateSaveCreate,
            onPressed: _isSaving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
