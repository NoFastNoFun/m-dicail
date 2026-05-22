import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  const Contact({
    this.phone,
    this.email,
    this.address,
  });

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
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
    };
  }

  @override
  List<Object?> get props => [phone, email, address];
}
