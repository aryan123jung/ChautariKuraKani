import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fname;
  final String lname;
  final String username;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? profilePicture;
  final String? coverPicture;
  final String? bio;

  AuthApiModel({
    this.id,
    required this.fname,
    required this.lname,
    required this.username,
    required this.email,
    this.password,
    this.confirmPassword,
    this.profilePicture,
    this.coverPicture,
    this.bio,
  });

  // toJSON
  Map<String, dynamic> toJson() {
    return {
      'firstName': fname,
      'lastName': lname,
      'username': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword ?? password,
      'profilePicture': profilePicture,
      'coverPicture': coverPicture,
      'bio': bio,
    };
  }

  //fromJSON
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String?,
      fname: json['firstName'] as String,
      lname: json['lastName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      profilePicture: json['profilePicture'] as String?,
      coverPicture: json['coverPicture'] as String?,
      bio: json['bio'] as String?,
    );
  }

  //toEntity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      fName: fname,
      lName: lname,
      username: username,
      email: email,
      password: password,
      profilePicture: profilePicture,
      coverPicture: coverPicture,
      bio: bio,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      fname: entity.fName,
      lname: entity.lName,
      username: entity.username,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.password,
      profilePicture: entity.profilePicture,
      coverPicture: entity.coverPicture,
      bio: entity.bio,
    );
  }

  //toEntityList
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
