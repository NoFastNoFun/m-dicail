import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@lazySingleton
class AppInfo {
  AppInfo(this._packageInfo);

  final PackageInfo _packageInfo;

  String get appName => _packageInfo.appName;

  String get version => _packageInfo.version;

  String get buildNumber => _packageInfo.buildNumber;

  String get packageName => _packageInfo.packageName;
}

@module
abstract class AppInfoModule {
  @preResolve
  @lazySingleton
  Future<PackageInfo> packageInfo() => PackageInfo.fromPlatform();
}
