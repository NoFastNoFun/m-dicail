import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  const Contact({this.phone, this.email, this.address});

  final String? phone;
  final String? email;
  final String? address;

  Contact copyWith({
    String? phone,
    String? email,
    String? address,
    bool clearPhone = false,
    bool clearEmail = false,
    bool clearAddress = false,
  }) {
    return Contact(
      phone: clearPhone ? null : phone ?? this.phone,
      email: clearEmail ? null : email ?? this.email,
      address: clearAddress ? null : address ?? this.address,
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      phone: _blankToNull(json['phone'] as String?),
      email: _blankToNull(json['email'] as String?),
      address: _blankToNull(json['address'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': _blankToNull(phone),
      'email': _blankToNull(email),
      'address': _blankToNull(address),
    };
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  @override
  List<Object?> get props => [phone, email, address];
}
