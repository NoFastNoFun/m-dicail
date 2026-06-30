import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_typography.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/widget/inputs/input_validators.dart';

enum AppInputVariant { text, number, email, password, textarea }

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.variant,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.messageResolver,
    this.maxLength,
    this.maxLines,
    this.prefixIcon,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final AppInputVariant variant;
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;
  final String? Function(String validationKey)? messageResolver;
  final int? maxLength;
  final int? maxLines;
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _obscurePassword = true;

  static final _errorBorder = OutlineInputBorder(
    borderRadius: AppRadius.mdBorder,
    borderSide: const BorderSide(color: AppColors.error, width: 1.5),
  );

  static final _focusedErrorBorder = OutlineInputBorder(
    borderRadius: AppRadius.mdBorder,
    borderSide: const BorderSide(color: AppColors.error, width: 2),
  );

  String? _defaultValidator(String? value) {
    final key = switch (widget.variant) {
      AppInputVariant.text => InputValidators.validateText(value),
      AppInputVariant.number => InputValidators.validateNumber(value),
      AppInputVariant.email => InputValidators.validateEmail(value),
      AppInputVariant.password => InputValidators.validatePassword(value),
      AppInputVariant.textarea => InputValidators.validateTextarea(value),
    };
    if (key == null) return null;
    return widget.messageResolver?.call(key) ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final secondaryColor = context.secondaryTextColor;
    final errorColor = Theme.of(context).colorScheme.error;

    final effectiveValidator = widget.validator ?? _defaultValidator;
    final isPassword = widget.variant == AppInputVariant.password;
    final isTextarea = widget.variant == AppInputVariant.textarea;
    final lines = widget.maxLines ?? (isTextarea ? 4 : 1);

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: isPassword && _obscurePassword,
      keyboardType: _keyboardType(),
      inputFormatters: _inputFormatters(),
      maxLines: isPassword ? 1 : lines,
      maxLength: widget.maxLength,
      autovalidateMode: widget.autovalidateMode,
      validator: (value) {
        if (widget.errorText != null) return widget.errorText;
        return effectiveValidator(value);
      },
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        errorStyle: AppTypography.caption.copyWith(color: errorColor),
        errorBorder: _errorBorder,
        focusedErrorBorder: _focusedErrorBorder,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: secondaryColor)
            : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: secondaryColor,
                ),
                onPressed: widget.enabled && !widget.readOnly
                    ? () => setState(() => _obscurePassword = !_obscurePassword)
                    : null,
              )
            : null,
      ),
    );
  }

  TextInputType _keyboardType() {
    return switch (widget.variant) {
      AppInputVariant.number =>
        const TextInputType.numberWithOptions(decimal: true),
      AppInputVariant.email => TextInputType.emailAddress,
      AppInputVariant.password => TextInputType.visiblePassword,
      AppInputVariant.textarea => TextInputType.multiline,
      AppInputVariant.text => TextInputType.text,
    };
  }

  List<TextInputFormatter>? _inputFormatters() {
    if (widget.variant == AppInputVariant.number) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]')),
      ];
    }
    return null;
  }
}
