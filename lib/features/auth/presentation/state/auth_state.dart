


import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

/// ✅ Possible authentication states
enum AuthStatus {
  initial,
  checking,        // checking for existing user/token
  loading,         // during login/register/logout
  authenticated,
  unauthenticated,
  registered,
  error,
  currentUserLoaded,
}

/// 🔐 Authentication state
class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.authEntity,
    this.errorMessage,
  });

  /// Initial state
  const AuthState.initial()
      : status = AuthStatus.initial,
        authEntity = null,
        errorMessage = null;

  /// CopyWith with optional clearing of authEntity
  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    bool clearAuthEntity = false,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: clearAuthEntity ? null : authEntity ?? this.authEntity,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage];

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
