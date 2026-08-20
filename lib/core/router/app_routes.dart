abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String record = '/record';
  static const String patients = '/patients';
  static const String patientDetail = '/patients/:patientId';
  static const String appointments = '/appointments';
  static const String settings = '/settings';
  static const String medicalWatch = '/medical_watch';
  static const String settingsTemplates = '/settings/templates';
  static const String templateCreate = '/settings/templates/new';
  static const String templateEditor = '/settings/templates/:templateId/edit';
  static const String debug = '/debug';

  static String templateEditorPath(String templateId) =>
      '/settings/templates/$templateId/edit';
}
