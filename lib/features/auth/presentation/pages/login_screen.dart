import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/dashboard/presentation/pages/dashboard_screen.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
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

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _handleForgotPassword() {
    SnackbarUtils.showInfo(context, 'Forgot password feature coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // ref.listen<AuthState>(authViewModelProvider, (previous, next) {
    //   if (next.status == AuthStatus.authenticated) {
    //     // SnackbarUtils.showSuccess(context, 'Login successful');
    //     AppRoutes.pushReplacement(context, DashboardScreen());
    //   } else if (next.status == AuthStatus.error && next.errorMessage != null) {
    //     SnackbarUtils.showError(context, next.errorMessage!);
    //   }
    // });

    // ref.listen<AuthState>(authViewModelProvider, (previous, next) {
    //   // Only navigate when login is successful (not on first build)
    //   if (next.status == AuthStatus.authenticated &&
    //       previous?.status != AuthStatus.authenticated) {
    //     AppRoutes.pushReplacement(context, DashboardScreen());
    //   } else if (next.status == AuthStatus.error && next.errorMessage != null) {
    //     SnackbarUtils.showError(context, next.errorMessage!);
    //   }
    // });
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Login successful');

        Future.microtask(() {
          AppRoutes.pushReplacement(context, DashboardScreen());
        });
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

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
                            // text: "Email",
                            // hintText: "Email",
                            // errorText: "Please enter your email",
                            // prefixIcon: Icons.email,
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
                            // text: "Password",
                            // hintText: "Password",
                            // errorText: "Please enter your password",
                            // prefixIcon: Icons.lock,
                            // isPassword: true,
                          ),

                          SizedBox(height: 30),

                          // Padding(
                          //   padding: EdgeInsets.fromLTRB(
                          //     isTablet ? 100 : 0,
                          //     0,
                          //     isTablet ? 100 : 0,
                          //     0,
                          //   ),
                          //   child: MyFloatingButton(
                          //     onPressed: _handleLogin,
                          //     text: "Log in",
                          //     color: const Color.fromARGB(255, 229, 163, 32),
                          //     isLoading: authState.status == AuthStatus.loading,
                          //   ),
                          // ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
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
                              child: authState.status == AuthStatus.loading
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
