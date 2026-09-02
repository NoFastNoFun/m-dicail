import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.fullName,
    this.mfaEnabled = false,
    this.hasPasskeys = false,
    this.medicalWatchDigestOptIn = false,
  });

  final String id;
  final String email;
  final String? fullName;
  final bool mfaEnabled;
  final bool hasPasskeys;
  final bool medicalWatchDigestOptIn;

  @override
  List<Object?> get props => [id, email, fullName, mfaEnabled, hasPasskeys, medicalWatchDigestOptIn];
}
