import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_two.dart';
import 'package:chautari_kurakani/widgets/my_elevated_button.dart';
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
          "Your Digital,\nChautari Awaits",
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

        SizedBox(height: isTablet ? 30 : 50),

        Image.asset("assets/images/splash_one.png", width: imageWidth),

        Padding(
          padding: EdgeInsets.fromLTRB(15, isTablet ? 0 : 30, 15, 15),
          child: Text(
            "Gather with friends, family and new faces. ChautariKuraKani is the welcoming space for authentic conversations and shared stories.",
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

        const SizedBox(height: 40),

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
                  MaterialPageRoute(builder: (_) => const OnboardingTwo()),
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
                  "Your Digital,\nChautari Awaits",
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
                  "Gather with friends, family and new faces. ChautariKuraKani is the welcoming space for authentic conversations and shared stories.",
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnboardingTwo(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 40),

          Image.asset("assets/images/splash_one.png", width: imageWidth),
        ],
      ),
    );
  }
}
