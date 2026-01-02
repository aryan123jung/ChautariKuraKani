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
//   final AuthEntity? authEntity;
//   final String? errorMessage;

//   const AuthState({
//     this.status = AuthStatus.initial,
//     this.authEntity,
//     this.errorMessage,
//   });

//   const AuthState.initial()
//     : status = AuthStatus.unauthenticated,
//       authEntity = null,
//       errorMessage = null;

//   AuthState copyWith({
//     AuthStatus? status,
//     AuthEntity? authEntity,
//     String? errorMessage,
//   }) {
//     return AuthState(
//       status: status ?? this.status,
//       authEntity: authEntity ?? this.authEntity,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }

//   @override
//   List<Object?> get props => [status, authEntity, errorMessage];
// }

import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? authEntity;
  final String? errorMessage;

  const AuthState({required this.status, this.authEntity, this.errorMessage});

  const AuthState.initial()
    : status = AuthStatus.initial,
      authEntity = null,
      errorMessage = null;

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? authEntity,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      authEntity: authEntity ?? this.authEntity,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, authEntity, errorMessage];
}
