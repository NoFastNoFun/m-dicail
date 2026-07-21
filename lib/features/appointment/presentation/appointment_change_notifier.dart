import 'package:flutter/foundation.dart';

/// Notifies listeners when appointments are created, updated, or removed
/// so screens that own a separate [AppointmentBloc] can refresh.
class AppointmentChangeNotifier extends ChangeNotifier {
  void notifyChanged() => notifyListeners();
}

final appointmentChangeNotifier = AppointmentChangeNotifier();
