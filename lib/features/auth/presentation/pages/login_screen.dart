import 'dart:async';

import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/services/storage/token_service.dart';
import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:chautari_kurakani/features/sensor/data/services/face_id_auth_service.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_outline_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _loginForm = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isBiometricLoading = false;
  bool _rememberFaceId = false;
  final FaceIdAuthService _faceIdAuthService = FaceIdAuthService();
  bool _didNavigateAfterLogin = false;
  ProviderSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadRememberFaceId();
    _authSubscription = ref.listenManual<AuthState>(authViewModelProvider, (
      previous,
      next,
    ) {
      final loginSuccess =
          next.status == AuthStatus.authenticated ||
          next.status == AuthStatus.currentUserLoaded;

      if (loginSuccess && !_didNavigateAfterLogin) {
        _didNavigateAfterLogin = true;
        final entity = next.authEntity;
        if (entity != null && (entity.authId ?? '').trim().isNotEmpty) {
          unawaited(_syncFaceIdSelection(entity));
          ref
              .read(userSessionServiceProvider)
              .saveUserSession(
                userId: entity.authId!,
                email: entity.email,
                fName: entity.fName,
                lName: entity.lName,
                username: entity.username,
                profilePicture: entity.profilePicture,
                coverPicture: entity.coverPicture,
                bio: entity.bio,
              );
        }
        if (!mounted) return;
        SnackbarUtils.showSuccess(context, 'Login successful');
        AppRoutes.pushReplacement(context, const DashboardScreen());
        return;
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });
  }

  Future<void> _loadRememberFaceId() async {
    final enabled = await ref.read(tokenServiceProvider).isBiometricEnabled();
    if (!mounted) return;
    setState(() {
      _rememberFaceId = enabled;
    });
  }

  Future<void> _onRememberFaceIdChanged(bool value) async {
    setState(() => _rememberFaceId = value);
    final tokenService = ref.read(tokenServiceProvider);
    await tokenService.setBiometricEnabled(value);
    if (!value) {
      await tokenService.removeBiometricToken();
    }
  }

  Future<void> _syncFaceIdSelection(AuthEntity entity) async {
    final tokenService = ref.read(tokenServiceProvider);
    if (!_rememberFaceId) {
      return;
    }

    final token = await tokenService.getToken();
    if (token == null || token.trim().isEmpty) return;

    await tokenService.saveBiometricToken(token);
    await tokenService.saveBiometricUserId(entity.authId ?? '');
  }

  @override
  void dispose() {
    _authSubscription?.close();
    _authSubscription = null;
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginForm.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (_isBiometricLoading) return;
    setState(() => _isBiometricLoading = true);

    try {
      final biometricEnabled = await ref
          .read(tokenServiceProvider)
          .isBiometricEnabled();
      if (!biometricEnabled) {
        if (!mounted) return;
        SnackbarUtils.showInfo(
          context,
          'Enable "Remember this account for Face ID" first.',
        );
        return;
      }
      final authResult = await _faceIdAuthService.authenticateForLogin();
      if (!authResult.success) {
        if (!mounted) return;
        if (authResult.message != null &&
            authResult.message!.trim().isNotEmpty) {
          SnackbarUtils.showError(context, authResult.message!);
        }
        return;
      }

      final tokenService = ref.read(tokenServiceProvider);
      String? token = await tokenService.getToken();
      token ??= await tokenService.getBiometricToken();
      if (token != null && token.trim().isNotEmpty) {
        await tokenService.saveToken(token);
      }

      final hasToken = token?.trim().isNotEmpty == true;
      final hasUserId =
          (ref.read(userSessionServiceProvider).getCurrentUserId() ?? '')
              .trim()
              .isNotEmpty;

      if (!hasToken && !hasUserId) {
        if (!mounted) return;
        SnackbarUtils.showInfo(
          context,
          'No saved session found. Please login once with email/password.',
        );
        return;
      }

      await ref.read(authViewModelProvider.notifier).getCurrentUser(userId: '');
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Biometric login failed');
    } finally {
      if (mounted) {
        setState(() => _isBiometricLoading = false);
      }
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _handleForgotPassword() {
    // SnackbarUtils.showInfo(context, 'Forgot password feature coming soon');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isAuthLoading = authState.status == AuthStatus.loading;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: isTablet ? 40 : 40),

              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 26,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/white_half_logo.png',
                  height: isTablet ? 200 : 100,
                  width: isTablet ? 200 : 100,
                ),
              ),

              SizedBox(height: isTablet ? 30 : 20),

              Text(
                "ChautariKuraKani",
                style: TextStyle(
                  fontSize: isTablet ? 70 : 40,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 0 : 5),

              Text(
                "Chautarimah Sabai Kura",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 28 : 20,
                ),
              ),

              SizedBox(height: isTablet ? 100 : 40),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? screenWidth * 0.2 : 13,
                ),
                child: Container(
                  width: isTablet ? screenWidth * 0.6 : double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _loginForm,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 45 : 15,
                        20,
                        isTablet ? 45 : 15,
                        30,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 20),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              hintText: "Enter your email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 10),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter your password",
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 30),

                          SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ElevatedButton(
                                    onPressed: isAuthLoading
                                        ? null
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        229,
                                        163,
                                        32,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child:
                                        authState.status == AuthStatus.loading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            "Log in",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        (_isBiometricLoading || isAuthLoading)
                                        ? null
                                        : _handleBiometricLogin,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0XFF76C05D),
                                        width: 1.3,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isBiometricLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.face_retouching_natural,
                                            color: Color(0XFF76C05D),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberFaceId,
                                onChanged: (value) {
                                  if (value == null) return;
                                  unawaited(_onRememberFaceIdChanged(value));
                                },
                                activeColor: const Color(0XFF76C05D),
                              ),
                              const SizedBox(width: 2),
                              const Expanded(
                                child: Text(
                                  'Remember this account for Face ID',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          MyTextButton(
                            onPressed: _handleForgotPassword,
                            text: "Forgot Password?",
                            textColor: const Color.fromARGB(255, 63, 124, 42),
                          ),

                          SizedBox(height: 20),

                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? 100 : 0,
                              0,
                              isTablet ? 100 : 0,
                              0,
                            ),
                            child: MyOutlinedButton(
                              onPressed: _navigateToSignup,
                              text: "Create new account",
                              borderColor: const Color(0xFF76C05D),
                              textColor: const Color(0xFF717171),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
