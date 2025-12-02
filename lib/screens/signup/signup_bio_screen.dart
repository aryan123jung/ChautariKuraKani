import 'package:chautari_kurakani/screens/home_screen.dart';
import 'package:chautari_kurakani/screens/signup/signup_coverpicture_screen.dart';
import 'package:chautari_kurakani/widgets/my_floating_button.dart';
import 'package:chautari_kurakani/widgets/my_text_field.dart';
import 'package:flutter/material.dart';

class SignupBioScreen extends StatefulWidget {
  const SignupBioScreen({super.key});

  @override
  State<SignupBioScreen> createState() => _SignupBioScreenState();
}

class _SignupBioScreenState extends State<SignupBioScreen> {
  final TextEditingController bioController = TextEditingController();
  final _signupKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    bool isTablet = screenWidth > 600;
    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
        
              Padding(
                padding:  EdgeInsets.fromLTRB(0,0,isTablet? 350:350,0),
                child: InkWell(
                  onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupCoverpictureScreen()));},
                
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.black, 
                  size: 30.0, 
                  semanticLabel: 'Back button', 
                  
                ),
                ),
              ),
        
              SizedBox(height: isTablet ? 10 : 10),
        
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
                  height: isTablet ? 110 : 100,
                  width: isTablet ? 110 : 100,
                  // width: 100,
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
        
                          SizedBox(height: isTablet ? 15 : 15),
        
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 10, 140, 0),
                            child: Text(
                              "Write some fun bio!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(255, 69, 65, 54),
                              ),
                            ),
                          ),
        
                          SizedBox(height: isTablet? 40:40,),
        
                          MyTextfield(controller: bioController, text: "Bio", errorText: ''),
        
                          
                          SizedBox(height: isTablet ? 40 : 40),
        
                          
        
                          MyFloatingButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen(),
                                ),
                              );
                            },
                            text: "Finish",
                            color: const Color.fromARGB(255, 229, 163, 32),
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
      ),
    );
  }
}

  