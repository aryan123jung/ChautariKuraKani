// import 'package:chautari_kurakani/core/services/hive/hive_service.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/login_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/register_usecase.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUseCase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String fName,
    required String lName,
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    await Future.delayed(const Duration(seconds: 2));

    final params = RegisterUsecaseParams(
      fName: fName,
      lName: lName,
      email: email,
      username: username,
      password: password,
    );
    final result = await _registerUseCase.call(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
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
    await Future.delayed(const Duration(seconds: 1));

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

  
}
