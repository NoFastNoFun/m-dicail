import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/appointment/presentation/appointment_bloc.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/widget/app_text.dart';

class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = context.watch<AuthBloc>().state;

    String greeting;
    if (authState is AuthAuthenticated &&
        authState.user.fullName != null &&
        authState.user.fullName!.trim().isNotEmpty) {
      greeting = l10n.homeGreeting(authState.user.fullName!);
    } else {
      greeting = l10n.homeGreetingGuest;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          greeting,
          variant: AppTextVariant.headline,
        ),
        const SizedBox(height: AppSpacing.xs),
        BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, state) {
            final count = state is AppointmentDayLoaded
                ? state.items.length
                : 0;
            return AppText(
              l10n.homeConsultationsToday(count),
              variant: AppTextVariant.body,
              color: context.secondaryTextColor,
            );
          },
        ),
      ],
    );
  }
}
