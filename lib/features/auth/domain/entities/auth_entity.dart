import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? authId;
  final String fName;
  final String lName;
  final String email;
  final String? password;
  final String username;
  final String? profilePicture;

  const AuthEntity({
    this.authId,
    required this.fName,
    required this.lName,
    required this.email,
    this.password,
    required this.username,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    authId,
    fName,
    lName,
    email,
    password,
    username,
    profilePicture,
  ];
}
