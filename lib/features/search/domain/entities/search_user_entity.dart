import 'package:equatable/equatable.dart';

class SearchUserEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profileUrl;
  final String? coverUrl;

  const SearchUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.profileUrl,
    this.coverUrl,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    username,
    email,
    profileUrl,
    coverUrl,
  ];
}
