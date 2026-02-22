import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';

class SearchUserApiModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? profileUrl;
  final String? coverUrl;

  const SearchUserApiModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.profileUrl,
    this.coverUrl,
  });

  factory SearchUserApiModel.fromJson(Map<String, dynamic> json) {
    return SearchUserApiModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profileUrl: json['profileUrl']?.toString(),
      coverUrl: json['coverUrl']?.toString(),
    );
  }

  SearchUserEntity toEntity() {
    return SearchUserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      profileUrl: profileUrl,
      coverUrl: coverUrl,
    );
  }
}
