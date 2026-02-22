import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  checking,
  loading,
  searchingUsers,
  authenticated,
  unauthenticated,
  registered,
  error,
  loaded,
  currentUserLoaded,
  usersLoaded,
  success,
  passwordResetSuccess,
  passwordResetEmailSent,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  //store image name temporarily
  final String? uploadProfilePhotoName;
  final String? uploadCoverPhotoName;
  final List<AuthEntity> searchedUsers;

  const AuthState({
    required this.status,
    this.authEntity,
    this.errorMessage,
    this.uploadProfilePhotoName,
    this.uploadCoverPhotoName,
    this.searchedUsers = const [],
  });

  const AuthState.initial(
    this.uploadProfilePhotoName,
    this.uploadCoverPhotoName,
  ) : status = AuthStatus.initial,
      authEntity = null,
      errorMessage = null,
      searchedUsers = const [];

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    bool clearAuthEntity = false,
    String? errorMessage,
    String? uploadProfilePhotoName,
    String? uploadCoverPhotoName,
    List<AuthEntity>? searchedUsers,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: clearAuthEntity ? null : authEntity ?? this.authEntity,
      errorMessage: errorMessage,
      uploadProfilePhotoName:
          uploadProfilePhotoName ?? this.uploadProfilePhotoName,
      uploadCoverPhotoName: uploadCoverPhotoName ?? this.uploadCoverPhotoName,
      searchedUsers: searchedUsers ?? this.searchedUsers,
    );
  }

  @override
  List<Object?> get props => [
    status,
    authEntity,
    errorMessage,
    uploadProfilePhotoName,
    uploadCoverPhotoName,
    searchedUsers,
  ];

  @override
  String toString() =>
      'AuthState(status: $status, authEntity: $authEntity, errorMessage: $errorMessage)';
}
