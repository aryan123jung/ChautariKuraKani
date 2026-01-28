import 'package:chautari_kurakani/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/login_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/register_usecase.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUseCase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;
  late final GetCurrentUserUsecase _getCurrentUserUsecase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    return const AuthState(status: AuthStatus.checking);
  }

  /// 🔐 LOGIN
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = AuthState(status: AuthStatus.authenticated, authEntity: user);
      },
    );
  }

  /// 🧾 REGISTER
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

    final result = await _registerUseCase(
      RegisterUsecaseParams(
        fName: fName,
        lName: lName,
        email: email,
        username: username,
        password: password,
        profilePicture: profilePicture,
        coverPicture: coverPicture,
        bio: bio,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = AuthState(status: AuthStatus.registered, authEntity: user);
      },
    );
  }

  /// 🚪 LOGOUT
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _logoutUsecase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      },
    );
  }

  /// 🔄 GET CURRENT USER
  Future<void> getCurrentUser({required String userId}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final getCurrentUsecaseParams = GetCurrentUsecaseParams(userId: userId);
    final result = await _getCurrentUserUsecase(getCurrentUsecaseParams);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = AuthState(
          status: AuthStatus.currentUserLoaded,
          authEntity: user,
        );
      },
    );
  }
}
