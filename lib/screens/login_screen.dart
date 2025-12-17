import 'package:chautari_kurakani/screens/dashboard_screen.dart';
import 'package:chautari_kurakani/screens/forget_password/forget_password_screen.dart';
// import 'package:chautari_kurakani/screens/bottom_nav_screen/home_screen.dart';
import 'package:chautari_kurakani/screens/signup/signup_screen.dart';
import 'package:chautari_kurakani/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/widgets/my_outline_button.dart';
import 'package:chautari_kurakani/widgets/my_text_button.dart';
import 'package:chautari_kurakani/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginForm = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              SizedBox(height: isTablet ? 10 : 40),

              /// Logo
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
                  height: isTablet ? 110 : 100,
                  width: isTablet ? 110 : 100,
                ),
              ),

              SizedBox(height: isTablet ? 0 : 20),

              /// Title
              Text(
                "ChautariKuraKani",
                style: TextStyle(
                  fontSize: isTablet ? 50 : 40,
                  fontWeight: FontWeight.bold,
                  // fontFamily: 'OpenSans Bold',
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

              SizedBox(height: isTablet ? 30 : 40),

              /// Form Container
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? screenWidth * 0.2 : 13),
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
                        )
                      ]),
                  child: Form(
                    key: _loginForm,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          isTablet ? 45 : 15, 20, isTablet ? 45 : 15, 30),
                      child: Column(
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),

                          SizedBox(height: 20),

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

                          SizedBox(height: 30),

                          Padding(
                            padding:  EdgeInsets.fromLTRB(isTablet? 100: 0,0,isTablet? 100:0,0),
                            child: MyFloatingButton(
                              onPressed: () {
                                // Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
                              },
                              text: "Log in",
                              color: const Color.fromARGB(255, 229, 163, 32),
                            ),
                          ),

                          SizedBox(height: 20),

                          MyTextButton(
                            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgetPasswordScreen()));},
                            text: "Forgot Password?",
                            textColor: const Color.fromARGB(255, 63, 124, 42),
                          ),

                          SizedBox(height: 20),

                          Padding(
                            padding:  EdgeInsets.fromLTRB(isTablet? 100:0,0,isTablet? 100:0,0),
                            child: MyOutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupScreen(),
                                  ),
                                );
                              },
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
