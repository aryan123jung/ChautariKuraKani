import 'package:chautari_kurakani/core/constants/hive_table_constant.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;
  @HiveField(1)
  final String fName;
  @HiveField(2)
  final String lName;
  @HiveField(3)
  final String username;
  @HiveField(4)
  final String email;
  @HiveField(5)
  final String? password;
  @HiveField(6)
  final String? profilePicture;
  @HiveField(7)
  final String? coverPicture;
  @HiveField(8)
  final String? bio;

  AuthHiveModel({
    String? authId,
    required this.fName,
    required this.lName,
    required this.email,
    this.password,
    this.profilePicture,
    this.coverPicture,
    this.bio,
    required this.username,
  }) : authId = authId ?? Uuid().v4();

  //From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      fName: entity.fName,
      lName: entity.lName,
      username: entity.username,
      email: entity.email,
      password: entity.password,
      profilePicture: entity.profilePicture,
      coverPicture: entity.coverPicture,
      bio: entity.bio,
    );
  }
  //To Entity
  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      fName: fName,
      lName: lName,
      username: username,
      email: email,
      password: password,
      profilePicture: profilePicture,
      coverPicture: coverPicture,
      bio: bio,
    );
  }

  // To entity list
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
