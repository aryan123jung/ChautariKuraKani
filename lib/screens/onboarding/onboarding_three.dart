import 'package:chautari_kurakani/screens/login_screen.dart';
import 'package:chautari_kurakani/widgets/my_floating_button.dart';
import 'package:flutter/material.dart';

class OnboardingThree extends StatefulWidget {
  const OnboardingThree({super.key});

  @override
  State<OnboardingThree> createState() => _OnboardingThreeState();
}

class _OnboardingThreeState extends State<OnboardingThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(child: Column(
        children: [
          SizedBox(height: 10,),
         
              Text(
                "Connect \nAcross Borders",
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
            

          
          SizedBox(height: 30,),


          Image.asset("assets/images/splash_thre.png"),


          Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "Whether near or to far, join conversations relevant to your interest, region or culture. The world is waiting to chat",
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


            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: MyFloatingButton(
                
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                }, 
                text: "Next",
                color: const Color.fromARGB(255, 229, 163, 32),
              ),
            ),
        ],
      )),
    );
  }
}