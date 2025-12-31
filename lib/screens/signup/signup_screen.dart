import 'package:chautari_kurakani/features/login/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/screens/signup/signup_profilepicture_screen.dart';
import 'package:chautari_kurakani/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/widgets/my_text_button.dart';
import 'package:chautari_kurakani/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _signupForm = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: isTablet ? 40 : 40),

              // Image.asset('assets/images/white_half_logo.png',height: 100,width: 100,),
              Container(
                // height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 26,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/white_half_logo.png',
                  height: isTablet ? 200 : 100,
                  width: isTablet ? 200 : 100,
                  // width: 100,
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
                      offset: Offset(2, 3),
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

              SizedBox(height: isTablet ? 90 : 40),

              Padding(
                // padding: const EdgeInsets.all(13.0),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? screenWidth * 0.2 : 13,
                ),
                child: Container(
                  // height: 200,
                  // width: double.infinity,
                  width: isTablet ? screenWidth * 0.6 : double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E3E3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _signupForm,

                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 45 : 15,
                        20,
                        isTablet ? 45 : 15,
                        0,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Create an account",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: MyTextfield(
                                  controller: firstNameController,
                                  text: "First Name",
                                  hintText: "First Name",
                                  errorText: "Please enter your first name",
                                ),
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: MyTextfield(
                                  controller: lastNameController,
                                  text: "Last Name",
                                  hintText: "Last Name",
                                  errorText: "Please enter your last name",
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          MyTextfield(
                            controller: emailController,
                            text: "Email",
                            hintText: "Email",
                            errorText: "Please enter your email",
                            prefixIcon: Icons.email,
                          ),

                          SizedBox(height: 10),

                          MyTextfield(
                            controller: passwordController,
                            text: "Password",
                            hintText: "Password",
                            errorText: "Please enter your password",
                            prefixIcon: Icons.lock,
                            isPassword: true,
                          ),

                          SizedBox(height: 10),

                          MyTextfield(
                            controller: confirmPasswordController,
                            text: "Confirm Password",
                            hintText: "Confirm Password",
                            errorText: "Please enter your password",
                            prefixIcon: Icons.lock,
                            isPassword: true,
                          ),

                          SizedBox(height: 30),

                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? 100 : 0,
                              0,
                              isTablet ? 100 : 0,
                              0,
                            ),
                            child: MyFloatingButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SignupProfilepictureScreen(),
                                  ),
                                );
                              },
                              text: "Next",
                              color: const Color.fromARGB(255, 229, 163, 32),
                            ),
                          ),

                          SizedBox(height: 20),

                          MyTextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            text: "Already have an account??",
                            textColor: const Color.fromARGB(255, 63, 124, 42),
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
