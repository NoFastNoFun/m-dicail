import 'package:equatable/equatable.dart';

class PasskeyCredential extends Equatable {
  const PasskeyCredential({
    required this.id,
    required this.deviceName,
    required this.createdAt,
  });

  final String id;
  final String? deviceName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, deviceName, createdAt];
}
