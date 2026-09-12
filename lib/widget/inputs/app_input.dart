import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicail/core/config/app_platform.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
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
    this.suffixIcon,
    this.suffixText,
    this.textAlign,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.keyboardType,
    this.inputFormatters,
    this.autofillHints,
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
  final Widget? suffixIcon;
  /// Inline unit / hint rendered by [InputDecoration.suffixText].
  final String? suffixText;
  /// Optional alignment for compact numeric fields.
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _obscurePassword = true;

  OutlineInputBorder _errorBorder(BorderRadius borderRadius) =>
      OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      );

  OutlineInputBorder _focusedErrorBorder(BorderRadius borderRadius) =>
      OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      );

  BorderRadius _inputBorderRadius(BuildContext context) {
    final enabledBorder =
        Theme.of(context).inputDecorationTheme.enabledBorder;
    if (enabledBorder is OutlineInputBorder) {
      return enabledBorder.borderRadius;
    }
    return AppRadius.mdBorder;
  }

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

  Iterable<String>? _effectiveAutofillHints() {
    if (widget.autofillHints != null) return widget.autofillHints;
    return switch (widget.variant) {
      AppInputVariant.email => const [AutofillHints.email],
      AppInputVariant.password => const [AutofillHints.password],
      _ => null,
    };
  }

  /// Desktop number / short fields: denser padding, stable cursor, text mouse.
  /// Skip density when a custom [suffixIcon] is present — IconButtons need height.
  bool get _useDesktopCompactField {
    if (!isDesktopPlatform) return false;
    if (widget.suffixIcon != null) return false;
    return widget.variant == AppInputVariant.number ||
        widget.variant == AppInputVariant.text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = context.secondaryTextColor;
    final errorColor = theme.colorScheme.error;
    final borderRadius = _inputBorderRadius(context);

    final effectiveValidator = widget.validator ?? _defaultValidator;
    final isPassword = widget.variant == AppInputVariant.password;
    final isEmail = widget.variant == AppInputVariant.email;
    final isTextarea = widget.variant == AppInputVariant.textarea;
    final isNumber = widget.variant == AppInputVariant.number;
    final lines = widget.maxLines ?? (isTextarea ? 4 : 1);
    final disableSuggestions = isEmail || isPassword;
    final desktopCompact = _useDesktopCompactField;
    final desktopNumber = isDesktopPlatform && isNumber;
    final desktopField =
        isDesktopPlatform && !isTextarea && !isPassword;

    final baseStyle = theme.textTheme.bodyLarge;
    final fieldStyle = desktopCompact
        ? baseStyle?.copyWith(
            height: 1.25,
            fontSize: (baseStyle.fontSize ?? 16) - (desktopNumber ? 1 : 0),
          )
        : null;

    // Match body line height so the caret does not look oversized on desktop.
    final cursorHeight = desktopField
        ? ((fieldStyle?.fontSize ?? baseStyle?.fontSize ?? 16) *
            (fieldStyle?.height ?? baseStyle?.height ?? 1.25))
        : null;

    final EdgeInsetsGeometry? densePadding = desktopCompact
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          )
        : null;

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
      autofillHints: _effectiveAutofillHints(),
      autocorrect: !disableSuggestions,
      enableSuggestions: !disableSuggestions,
      style: fieldStyle,
      cursorHeight: cursorHeight,
      mouseCursor: desktopField || desktopCompact
          ? WidgetStateMouseCursor.textable
          : null,
      textAlign: widget.textAlign ?? TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
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
        errorStyle: AppTypography.caption.copyWith(
          color: errorColor,
          // Avoid tall error lines blowing up dense desktop Rows.
          height: desktopCompact ? 1.1 : null,
        ),
        errorBorder: _errorBorder(borderRadius),
        focusedErrorBorder: _focusedErrorBorder(borderRadius),
        isDense: desktopCompact,
        contentPadding: densePadding,
        suffixText: widget.suffixText,
        suffixStyle: theme.textTheme.labelLarge?.copyWith(
          color: secondaryColor,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: secondaryColor)
            : null,
        suffixIcon: widget.suffixIcon ??
            (isPassword
                ? IconButton(
                    tooltip: _obscurePassword
                        ? 'Afficher le mot de passe'
                        : 'Masquer le mot de passe',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: secondaryColor,
                    ),
                    onPressed: widget.enabled && !widget.readOnly
                        ? () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            )
                        : null,
                  )
                : null),
      ),
    );
  }

  TextInputType _keyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType!;
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
    if (widget.inputFormatters != null) return widget.inputFormatters!;
    if (widget.variant == AppInputVariant.number) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]')),
      ];
    }
    return null;
  }
}
