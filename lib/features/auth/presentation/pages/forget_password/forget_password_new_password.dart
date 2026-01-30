import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_pin_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class ForgetPasswordNewPassword extends StatefulWidget {
  const ForgetPasswordNewPassword({super.key});

  @override
  State<ForgetPasswordNewPassword> createState() =>
      _ForgetPasswordNewPasswordState();
}

class _ForgetPasswordNewPasswordState extends State<ForgetPasswordNewPassword> {
  final _forgetkey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

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
                        key: _forgetkey,
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
                                "Recover your password",
                                style: TextStyle(
                                  fontSize: isTablet ? 25 : 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              SizedBox(height: isTablet ? 55 : 35),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  0,
                                  isTablet ? 300 : 140,
                                  0,
                                ),
                                child: Text(
                                  "Enter your new password.",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),

                              SizedBox(height: 40),

                              MyTextfield(
                                controller: newPasswordController,
                                text: "New Password",
                                errorText: "Please enter your password",
                              ),
                              SizedBox(height: 14),
                              MyTextfield(
                                controller: confirmPasswordController,
                                text: "Confirm Password",
                                errorText: "Please enter your password",
                              ),

                              SizedBox(height: 30),

                              SizedBox(height: 40),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isTablet ? 100 : 0,
                                  0,
                                  isTablet ? 100 : 0,
                                  0,
                                ),
                                child: MyElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  },
                                  text: "Confirm",
                                  color: const Color.fromARGB(
                                    255,
                                    229,
                                    163,
                                    32,
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgetPasswordPinScreen(),
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
