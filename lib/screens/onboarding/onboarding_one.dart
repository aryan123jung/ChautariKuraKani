import 'package:chautari_kurakani/screens/onboarding/onboarding_two.dart';
import 'package:chautari_kurakani/widgets/my_elevated_button.dart';
// import 'package:chautari_kurakani/widgets/my_outline_button.dart';
import 'package:flutter/material.dart';

class OnboardingOne extends StatefulWidget {
  const OnboardingOne({super.key});

  @override
  State<OnboardingOne> createState() => _OnboardingOneState();
}

class _OnboardingOneState extends State<OnboardingOne> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;
    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: Column(
          children: [


            SizedBox(height:isTablet ? 0: 20,),
         
              Text(
                "Your Digital,\nChautari Awaits",
                style: TextStyle(
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 9,
                      offset: const Offset(2, 3),
                    ),
                  ],
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            

          
          SizedBox(height: isTablet ? 0: 50,),


            Image.asset("assets/images/splash_one.png"),

            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "Gather with friends, family and new faces. ChautariKuraKani is the welcoming space for authentic conversations and shared stories.",
                style: TextStyle(
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 9,
                      offset: const Offset(2, 3),
                    ),
                  ],
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height:isTablet ? 0: 10),

            Padding(
              padding: EdgeInsets.fromLTRB(isTablet? 400:20,20,isTablet? 400:20,isTablet?10:20),
              child: MyFloatingButton(
                
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OnboardingTwo()));
                }, 
                text: "Next",
                color: const Color.fromARGB(255, 229, 163, 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
