import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

/// ✅ Possible authentication states
enum AuthStatus {
  initial,
  checking, // checking for existing user/token
  loading, // during login/register/logout
  authenticated,
  unauthenticated,
  registered,
  error,
  loaded,
  currentUserLoaded,
}

/// 🔐 Authentication state
class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;
  //store image name temporarily
  final String? uploadProfilePhotoName;
  final String? uploadCoverPhotoName;

  const AuthState({
    required this.status,
    this.authEntity,
    this.errorMessage,
    this.uploadProfilePhotoName,
    this.uploadCoverPhotoName,
  });

  /// Initial state
  const AuthState.initial(
    this.uploadProfilePhotoName,
    this.uploadCoverPhotoName,
  ) : status = AuthStatus.initial,
      authEntity = null,
      errorMessage = null;

  /// CopyWith with optional clearing of authEntity
  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    bool clearAuthEntity = false,
    String? errorMessage,
    String? uploadProfilePhotoName,
    String? uploadCoverPhotoName,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: clearAuthEntity ? null : authEntity ?? this.authEntity,
      errorMessage: errorMessage,
      uploadProfilePhotoName:
          uploadProfilePhotoName ?? this.uploadProfilePhotoName,
      uploadCoverPhotoName: uploadCoverPhotoName ?? this.uploadCoverPhotoName,
    );
  }

  @override
  List<Object?> get props => [
    status,
    authEntity,
    errorMessage,
    uploadProfilePhotoName,
    uploadCoverPhotoName,
  ];

  @override
  String toString() =>
      'AuthState(status: $status, authEntity: $authEntity, errorMessage: $errorMessage)';
}

// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:equatable/equatable.dart';

// enum AuthStatus {
//   initial,
//   loading,
//   authenticated,
//   unauthenticated,
//   registered,
//   error,
// }

// class AuthState extends Equatable {
//   final AuthStatus status;
//   final AuthEntity? user;
//   final String? errorMessage;

//   const AuthState({
//     this.status = AuthStatus.initial,
//     this.user,
//     this.errorMessage,
//   });

//   AuthState copyWith({
//     AuthStatus? status,
//     AuthEntity? user,
//     String? errorMessage,
//   }) {
//     return AuthState(
//       status: status ?? this.status,
//       user: user ?? this.user,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }

//   @override
//   List<Object?> get props => [status, user, errorMessage];
// }
