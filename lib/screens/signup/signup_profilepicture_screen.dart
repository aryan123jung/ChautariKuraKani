import 'package:chautari_kurakani/screens/signup/signup_coverpicture_screen.dart';
import 'package:chautari_kurakani/screens/signup/signup_screen.dart';
import 'package:chautari_kurakani/widgets/my_elevated_button.dart';
import 'package:flutter/material.dart';

class SignupProfilepictureScreen extends StatefulWidget {
  const SignupProfilepictureScreen({super.key});

  @override
  State<SignupProfilepictureScreen> createState() =>
      _SignupProfilepictureScreenState();
}

class _SignupProfilepictureScreenState
    extends State<SignupProfilepictureScreen> {
  final _signupKey = GlobalKey<FormState>();

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
                  SizedBox(height: isTablet ? 10 : 40),

                  Container(
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
                      height: isTablet ? 110 : 100,
                      width: isTablet ? 110 : 100,
                    ),
                  ),

                  SizedBox(height: isTablet ? 0 : 20),

                  Text(
                    "ChautariKuraKani",
                    style: TextStyle(
                      fontSize: isTablet ? 50 : 40,
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
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 28 : 20,
                    ),
                  ),

                  SizedBox(height: isTablet ? 30 : 40),

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
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _signupKey,
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
                                "Create your profile",
                                style: TextStyle(
                                  fontSize: isTablet? 25: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: isTablet ? 15 : 15),

                              Padding(
                                padding:
                                     EdgeInsets.fromLTRB(0, 10, isTablet? 450:140, 0),
                                child: Text(
                                  "Your profile picture.",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        const Color.fromARGB(255, 69, 65, 54),
                                  ),
                                ),
                              ),

                              SizedBox(height: isTablet ? 10 : 30),

                              Container(
                                height: isTablet ? 180 : 140,
                                width: isTablet ? 180 : 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE3E3E3),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: isTablet ? 60 : 50,
                                  color:
                                      const Color.fromARGB(255, 120, 120, 120),
                                ),
                              ),

                              SizedBox(height: isTablet ? 40 : 40),

                              Text(
                                "Tap above to choose image",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              SizedBox(height: 30),

                              Padding(
                                padding:  EdgeInsets.fromLTRB(isTablet? 100:0,0,isTablet? 100:0,0),
                                child: MyFloatingButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SignupCoverpictureScreen(),
                                      ),
                                    );
                                  },
                                  text: "Next",
                                  color:
                                      const Color.fromARGB(255, 229, 163, 32),
                                ),
                              ),

                              SizedBox(height: isTablet ? 30 : 30),
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
                  size: 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupScreen(),
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
