import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, required this.email, this.fullName});

  final String id;
  final String email;
  final String? fullName;

  @override
  List<Object?> get props => [id, email, fullName];
}
