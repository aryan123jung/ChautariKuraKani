import 'package:chautari_kurakani/screens/forget_password/forget_password_new_password.dart';
import 'package:chautari_kurakani/screens/forget_password/forget_password_screen.dart';
import 'package:chautari_kurakani/widgets/my_floating_button.dart';
import 'package:chautari_kurakani/widgets/my_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ForgetPasswordPinScreen extends StatefulWidget {
  const ForgetPasswordPinScreen({super.key});

  @override
  State<ForgetPasswordPinScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordPinScreen> {
  final _forgetPinKey = GlobalKey<FormState>();


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

                  Text(
                    "ChautariKuraKani",
                    style: TextStyle(
                      fontSize: isTablet ? 50 : 40,
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
                    ),
                  ),

                  SizedBox(height: isTablet ? 30 : 60),

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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              SizedBox(height: 40),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,0,60,0),
                                child: Text("Enter the code sent to your mail.",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
                              ),

                              SizedBox(height: 40),



                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: PinCodeTextField(
                                  length: 4,
                                  appContext: context,
                                  cursorHeight: 20,
                                  enableActiveFill: true,
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],

                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(8),
                                    fieldWidth: 50,

                                    activeColor:
                                        Colors.grey, 
                                    inactiveColor: Colors.grey,
                                    selectedColor: Colors.grey,

                                    activeFillColor: Colors.white,
                                    inactiveFillColor: Colors.white,
                                    selectedFillColor: const Color.fromARGB(
                                        255, 201, 209, 212),
                                  ),

                                  onChanged: (value) {},
                                ),
                              ),

                              SizedBox(height: 15,),

                              Padding(
                                padding: const EdgeInsets.fromLTRB(240,0,0,0),
                                child: MyTextButton(onPressed: (){}, text: "Resend",textColor: const Color.fromARGB(255, 63, 124, 42) ,),
                              ),

                              SizedBox(height: 20),


                              MyFloatingButton(
                                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordNewPassword()));}, 
                                  text: "Next"),

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
              child: Container(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Colors.black, size: 26),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPasswordScreen()));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
