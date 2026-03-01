import 'package:chautari_kurakani/common/my_snackbar.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_new_password.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgetPasswordPinScreen extends ConsumerStatefulWidget {
  final String email;
  const ForgetPasswordPinScreen({super.key, required this.email});

  @override
  ConsumerState<ForgetPasswordPinScreen> createState() =>
      _ForgetPasswordPinScreenState();
}

class _ForgetPasswordPinScreenState
    extends ConsumerState<ForgetPasswordPinScreen> {
  final _forgetPinKey = GlobalKey<FormState>();
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                      fontSize: isTablet ? 28 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: isTablet ? 100 : 60),
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
                        key: _forgetPinKey,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            isTablet ? 45 : 15,
                            20,
                            isTablet ? 45 : 15,
                            20,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Recover your password",
                                style: TextStyle(
                                  fontSize: isTablet ? 25 : 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: isTablet ? 55 : 40),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  0,
                                  isTablet ? 120 : 0,
                                  0,
                                ),
                                child: Text(
                                  "Enter the 6-digit code sent to ${widget.email}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isTablet
                                        ? FontWeight.bold
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(height: isTablet ? 50 : 40),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 80 : 10,
                                ),
                                child: PinCodeTextField(
                                  length: 6,
                                  appContext: context,
                                  cursorHeight: 20,
                                  enableActiveFill: true,
                                  keyboardType: TextInputType.number,
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(8),
                                    fieldWidth: isTablet ? 52 : 42,
                                    activeColor: Colors.grey,
                                    inactiveColor: Colors.grey,
                                    selectedColor: Colors.grey,
                                    activeFillColor: Colors.white,
                                    inactiveFillColor: Colors.white,
                                    selectedFillColor: const Color.fromARGB(
                                      255,
                                      201,
                                      209,
                                      212,
                                    ),
                                  ),
                                  onChanged: (value) => _code = value.trim(),
                                ),
                              ),
                              SizedBox(height: isTablet ? 5 : 15),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isTablet ? 400 : 240,
                                  0,
                                  0,
                                  0,
                                ),
                                child: MyTextButton(
                                  onPressed: () async {
                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .sendResetEmail(widget.email);
                                    if (!context.mounted) return;
                                    final state = ref.read(
                                      authViewModelProvider,
                                    );
                                    if (state.status ==
                                        AuthStatus.passwordResetEmailSent) {
                                      showMySnackBar(
                                        context: context,
                                        message: "Code resent successfully.",
                                        color: Colors.blueGrey,
                                      );
                                    } else if (state.status ==
                                        AuthStatus.error) {
                                      showMySnackBar(
                                        context: context,
                                        message:
                                            state.errorMessage ??
                                            "Failed to resend code",
                                        color: Colors.red,
                                      );
                                    }
                                  },
                                  text: "Resend",
                                  textColor: const Color.fromARGB(
                                    255,
                                    63,
                                    124,
                                    42,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isTablet ? 100 : 0,
                                  0,
                                  isTablet ? 100 : 0,
                                  0,
                                ),
                                child: MyElevatedButton(
                                  onPressed: () async {
                                    if (!RegExp(r'^\d{6}$').hasMatch(_code)) {
                                      showMySnackBar(
                                        context: context,
                                        message:
                                            "Please enter valid 6-digit code",
                                        color: Colors.red,
                                      );
                                      return;
                                    }

                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .verifyResetCode(
                                          email: widget.email,
                                          code: _code,
                                        );
                                    if (!context.mounted) return;
                                    final state = ref.read(
                                      authViewModelProvider,
                                    );
                                    if (state.status == AuthStatus.error) {
                                      showMySnackBar(
                                        context: context,
                                        message:
                                            state.errorMessage ??
                                            "Invalid or expired code",
                                        color: Colors.red,
                                      );
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ForgetPasswordNewPassword(
                                              email: widget.email,
                                              code: _code,
                                            ),
                                      ),
                                    );
                                  },
                                  text: "Next",
                                  color: const Color.fromARGB(
                                    255,
                                    229,
                                    163,
                                    32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgetPasswordScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
