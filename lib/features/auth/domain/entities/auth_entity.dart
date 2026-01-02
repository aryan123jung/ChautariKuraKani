// import 'package:equatable/equatable.dart';

// class AuthEntity extends Equatable {
//   final String? authId;
//   final String fName;
//   final String lName;
//   final String email;
//   final String? password;
//   final String username;
//   final String? profilePicture;
//   final String? coverPicture;
//   final String? bio;

//   const AuthEntity({
//     this.authId,
//     required this.fName,
//     required this.lName,
//     required this.email,
//     this.password,
//     required this.username,
//     this.profilePicture,
//     this.coverPicture,
//     this.bio,
//   });

//   @override
//   List<Object?> get props => [
//     authId,
//     fName,
//     lName,
//     email,
//     password,
//     username,
//     profilePicture,
//     coverPicture,
//     bio,
//   ];
// }
class AuthEntity {
  final String? authId;
  final String fName;
  final String lName;
  final String email;
  final String username;
  final String? password;
  final String? profilePicture;
  final String? coverPicture;
  final String? bio;

  const AuthEntity({
    required this.fName,
    required this.lName,
    required this.email,
    required this.username,
    this.password,
    this.profilePicture,
    this.coverPicture,
    this.bio,
    this.authId,
  });

  AuthEntity copyWith({
    String? authId,
    String? fName,
    String? lName,
    String? email,
    String? username,
    String? password,
    String? profilePicture,
    String? coverPicture,
    String? bio,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
      coverPicture: coverPicture ?? this.coverPicture,
      bio: bio ?? this.bio,
    );
  }
}






