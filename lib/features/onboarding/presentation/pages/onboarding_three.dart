import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingThree extends StatefulWidget {
  const OnboardingThree({super.key});

  @override
  State<OnboardingThree> createState() => _OnboardingThreeState();
}

class _OnboardingThreeState extends State<OnboardingThree> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;

    bool isTablet = screenWidth > 600;

    double titleFont = isTablet ? 42 : 36;
    double descFont = isTablet ? 22 : 20;
    double imageWidth = isTablet && orientation == Orientation.landscape
        ? screenWidth * 0.4
        : screenWidth * 0.8;

    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: isTablet && orientation == Orientation.landscape
            ? _tabletLandscapeLayout(context, titleFont, descFont, imageWidth)
            : _defaultLayout(
                context,
                titleFont,
                descFont,
                imageWidth,
                isTablet,
              ),
      ),
    );
  }

  Widget _defaultLayout(
    BuildContext context,
    double titleFont,
    double descFont,
    double imageWidth,
    bool isTablet,
  ) {
    return Column(
      children: [
        SizedBox(height: isTablet ? 50 : 35),

        Text(
          "Connect \nAcross Borders",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFont,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 9,
                offset: const Offset(2, 3),
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 0 : 50),

        Image.asset("assets/images/splash_thre.png", width: imageWidth * 0.9),

        Padding(
          padding: EdgeInsets.fromLTRB(15, isTablet ? 0 : 30, 15, 15),
          child: Text(
            "Whether near or far, join conversations relevant to your interest, region or culture. The world is waiting to chat",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descFont,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 9,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: isTablet ? 60 : 40),

        SizedBox(
          width: isTablet ? 320 : double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MyFloatingButton(
              text: "Next",
              color: const Color.fromARGB(255, 229, 163, 32),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabletLandscapeLayout(
    BuildContext context,
    double titleFont,
    double descFont,
    double imageWidth,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Connect \nAcross Borders",
                  style: TextStyle(
                    fontSize: titleFont,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 9,
                        offset: const Offset(2, 3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Whether near or far, join conversations relevant to your interest, region or culture. The world is waiting to chat",
                  style: TextStyle(
                    fontSize: descFont,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: 260,
                  child: MyFloatingButton(
                    text: "Next",
                    color: const Color.fromARGB(255, 229, 163, 32),
                    // onPressed: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
                    //   );
                    // },
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_done', true);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }

                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          Image.asset("assets/images/splash_thre.png", width: imageWidth),
        ],
      ),
    );
  }
}
