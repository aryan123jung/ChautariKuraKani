import 'dart:io';

import 'package:chautari_kurakani/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/get_current_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/login_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/register_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/upload_cover_image_usecase.dart';
import 'package:chautari_kurakani/features/auth/domain/usecases/upload_profile_image_usecase.dart';
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
  late final UploadProfileImageUsecase _uploadProfileImageUsecase;
  late final UploadCoverImageUsecase _uploadCoverImageUsecase;
  late final ForgotPasswordUsecase _forgotPasswordUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;

  @override
  AuthState build() {
    _registerUseCase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    _getCurrentUserUsecase = ref.read(getCurrentUserUsecaseProvider);
    _uploadProfileImageUsecase = ref.read(uploadProfileImageUsecaseProvider);
    _uploadCoverImageUsecase = ref.read(uploadCoverImageUsecaseProvider);
    _forgotPasswordUsecase = ref.read(forgotPasswordUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);

    return const AuthState(status: AuthStatus.checking);
  }

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

  Future<void> register({
    required String fName,
    required String lName,
    required String email,
    required String username,
    required String password,
    // String? profilePicture,
    // String? coverPicture,
    // String? bio,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUseCase(
      RegisterUsecaseParams(
        fName: fName,
        lName: lName,
        email: email,
        username: username,
        password: password,
        // profilePicture: profilePicture,
        // coverPicture: coverPicture,
        // bio: bio,
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

  Future<void> uploadProfileImage(File image) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadProfileImageUsecase(image);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (imageName) {
        state = state.copyWith(
          status: AuthStatus.loaded,
          uploadProfilePhotoName: imageName,
        );
      },
    );
  }

  Future<void> uploadCoverImage(File image) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadCoverImageUsecase(image);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (imageName) {
        state = state.copyWith(
          status: AuthStatus.loaded,
          uploadCoverPhotoName: imageName,
        );
      },
    );
  }

  Future<void> sendResetEmail(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _forgotPasswordUsecase(email);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.passwordResetEmailSent);
      },
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _resetPasswordUsecase(
      token: token,
      newPassword: newPassword,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(status: AuthStatus.passwordResetSuccess);
      },
    );
  }
}
