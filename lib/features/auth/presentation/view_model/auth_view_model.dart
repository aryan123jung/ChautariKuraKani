// // import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:chautari_kurakani/features/auth/domain/usecases/login_usecase.dart';
// import 'package:chautari_kurakani/features/auth/domain/usecases/register_usecase.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Provider
// final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
//   () => AuthViewModel(),
// );

// class AuthViewModel extends Notifier<AuthState> {
//   late final RegisterUsecase _registerUseCase;
//   late final LoginUsecase _loginUsecase;

//   @override
//   AuthState build() {
//     _registerUseCase = ref.read(registerUsecaseProvider);
//     _loginUsecase = ref.read(loginUsecaseProvider);
//     return AuthState();
//   }

// Future<void> register({
//   required String fName,
//   required String lName,
//   required String email,
//   required String username,
//   required String password,
//   String? profilePicture,
//   String? coverPicture,
//   String? bio,
// }) async {
//   state = state.copyWith(status: AuthStatus.loading);

//   await Future.delayed(const Duration(seconds: 2));

//   final params = RegisterUsecaseParams(
//     fName: fName,
//     lName: lName,
//     email: email,
//     username: username,
//     password: password,
//     profilePicture: profilePicture,
//     coverPicture: coverPicture,
//     bio: bio,
//   );
//   final result = await _registerUseCase.call(params);
//   result.fold(
//     (failure) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: failure.message,
//       );
//     },
//     (isRegistered) {
//       // Debug: Print registered users for verification
//       final hiveService = ref.read(hiveServiceProvider);
//       final users = hiveService.getAllAuths();
//       print('📝 Registered Users:');
//       for (var user in users) {
//         print('  - Name: ${user.fName} ${user.lName}');
//         print('  - Email: ${user.email}');
//         print('  - Username: ${user.username}');
//         print('  - Auth ID: ${user.authId}');
//         print('  ---');
//       }

//       if (isRegistered) {
//         // After successful registration, automatically authenticate the user
//         // by fetching their data from the database
//         final loginResult = _authRepository.login(email, password);
//         loginResult.fold(
//           (loginFailure) {
//             // If auto-login fails, just set as registered
//             state = state.copyWith(status: AuthStatus.registered);
//           },
//           (authEntity) {
//             // Auto-login successful
//             state = state.copyWith(
//               status: AuthStatus.authenticated,
//               authEntity: authEntity,
//             );
//           },
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Registration failed',
//         );
//       }
//     },
//   );
// }

//   Future<void> login({required String email, required String password}) async {
//     state = state.copyWith(status: AuthStatus.loading);
//     final params = LoginUsecaseParams(email: email, password: password);
//     await Future.delayed(const Duration(seconds: 1));

//     final result = await _loginUsecase.call(params);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: failure.message,
//         );
//       },
//       (authEntity) {
//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//         );
//       },
//     );
//   }

//   Future<void> logout() async {
//     state = state.copyWith(
//       status: AuthStatus.unauthenticated,
//       authEntity: null,
//     );
//   }
// }

// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
// import 'package:chautari_kurakani/features/auth/domain/usecases/login_usecase.dart';
// import 'package:chautari_kurakani/features/auth/domain/usecases/register_usecase.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
//   () => AuthViewModel(),
// );

// class AuthViewModel extends Notifier<AuthState> {
//   late final RegisterUsecase _registerUseCase;
//   late final LoginUsecase _loginUsecase;
//   final HiveService _hiveService = HiveService();
//   @override
//   AuthState build() {
//     _registerUseCase = ref.read(registerUsecaseProvider);
//     _loginUsecase = ref.read(loginUsecaseProvider);

//     Future.microtask(_loadCurrentUser);

//     return const AuthState.initial();
//   }

//   Future<void> _loadCurrentUser() async {
//     final hiveService = ref.read(hiveServiceProvider);
//     final users = hiveService.getAllAuths();

//     if (users.isNotEmpty) {
//       state = state.copyWith(
//         status: AuthStatus.authenticated,
//         authEntity: users.first.toEntity(),
//       );
//     }
//   }

//   Future<void> register({
//     required String fName,
//     required String lName,
//     required String email,
//     required String username,
//     required String password,
//     String? profilePicture,
//     String? coverPicture,
//     String? bio,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     final params = RegisterUsecaseParams(
//       fName: fName,
//       lName: lName,
//       email: email,
//       username: username,
//       password: password,
//       profilePicture: profilePicture,
//       coverPicture: coverPicture,
//       bio: bio,
//     );

//     final result = await _registerUseCase.call(params);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: failure.message,
//         );
//       },
//       (isRegistered) async {
//         if (isRegistered) {
//           // Debug: Print registered users for verification
//           final hiveService = ref.read(hiveServiceProvider);
//           final users = hiveService.getAllAuths();
//           print('📝 Registered Users:');
//           for (var user in users) {
//             print('  - Name: ${user.fName} ${user.lName}');
//             print('  - Email: ${user.email}');
//             print('  - Username: ${user.username}');
//             print('  - Auth ID: ${user.authId}');
//             print('  ---');
//           }

//           state = state.copyWith(status: AuthStatus.registered);

//           await Future.delayed(const Duration(milliseconds: 300));

//           // await _loadCurrentUser();
//         } else {
//           state = state.copyWith(
//             status: AuthStatus.error,
//             errorMessage: 'Registration failed',
//           );
//         }
//       },
//     );
//   }

//   Future<void> login({required String email, required String password}) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     final params = LoginUsecaseParams(email: email, password: password);

//     final result = await _loginUsecase.call(params);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: failure.message,
//         );
//       },
//       (authEntity) {
//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//         );
//       },
//     );
//   }

//   // Future<void> logout() async {
//   //   final hiveService = ref.read(hiveServiceProvider);

//   //   // Clear current user session
//   //   await hiveService.deleteAllAuths();

//   //   // Reset state
//   //   state = state.copyWith(
//   //     status: AuthStatus.unauthenticated,
//   //     authEntity: null,
//   //   );
//   // }
//   Future<void> logout() async {
//     await _hiveService.logoutUser();

//     // Reset any in-memory state if needed
//     state = AuthState.initial(); // or whatever your initial state is
//   }
// }

import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/login_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/register_usecase.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUseCase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);

    Future.microtask(_loadCurrentUser);

    return const AuthState.initial();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final hiveService = ref.read(hiveServiceProvider);
      final users = hiveService.getAllAuths();

      if (users.isNotEmpty) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: users.first.toEntity(),
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register({
    required String fName,
    required String lName,
    required String email,
    required String username,
    required String password,
    String? profilePicture,
    String? coverPicture,
    String? bio,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      fName: fName,
      lName: lName,
      email: email,
      username: username,
      password: password,
      profilePicture: profilePicture,
      coverPicture: coverPicture,
      bio: bio,
    );

    final result = await _registerUseCase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) async {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.registered);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Registration failed',
          );
        }
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(email: email, password: password);

    final result = await _loginUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          authEntity: null,
          errorMessage: null,
        );
      },
    );
  }

  void reset() {
    state = const AuthState.initial();
  }
}
