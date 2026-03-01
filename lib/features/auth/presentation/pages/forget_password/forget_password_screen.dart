// import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_new_password.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
// import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
// import 'package:chautari_kurakani/core/widgets/my_text_field.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ForgetPasswordScreen extends ConsumerStatefulWidget {
//   const ForgetPasswordScreen({super.key});

//   @override
//   ConsumerState<ForgetPasswordScreen> createState() =>
//       _ForgetPasswordScreenState();
// }

// class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
//   final _forgetkey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isTablet = screenWidth > 600;

//     return Scaffold(
//       backgroundColor: const Color(0xFF76C05D),

//       body: SafeArea(
//         child: Stack(
//           children: [
//             SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: isTablet ? 40 : 40),

//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha: 0.2),
//                           blurRadius: 26,
//                           spreadRadius: 1,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Image.asset(
//                       'assets/images/white_half_logo.png',
//                       height: isTablet ? 200 : 100,
//                       width: isTablet ? 200 : 100,
//                     ),
//                   ),

//                   SizedBox(height: isTablet ? 30 : 20),

//                   Text(
//                     "ChautariKuraKani",
//                     style: TextStyle(
//                       fontSize: isTablet ? 70 : 40,
//                       fontWeight: FontWeight.bold,
//                       shadows: [
//                         Shadow(
//                           color: Colors.black.withValues(alpha: 0.2),
//                           blurRadius: 15,
//                           offset: const Offset(2, 3),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: isTablet ? 0 : 5),

//                   Text(
//                     "Chautarimah Sabai Kura",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: isTablet ? 28 : 20,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),

//                   SizedBox(height: isTablet ? 100 : 60),

//                   Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isTablet ? screenWidth * 0.2 : 13,
//                     ),
//                     child: Container(
//                       width: isTablet ? screenWidth * 0.6 : double.infinity,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE3E3E3),
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.3),
//                             blurRadius: 12,
//                             spreadRadius: 2,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Form(
//                         key: _forgetkey,
//                         child: Padding(
//                           padding: EdgeInsets.fromLTRB(
//                             isTablet ? 45 : 15,
//                             20,
//                             isTablet ? 45 : 15,
//                             30,
//                           ),
//                           child: Column(
//                             children: [
//                               Text(
//                                 "Recover your password",
//                                 style: TextStyle(
//                                   fontSize: isTablet ? 25 : 20,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),

//                               SizedBox(height: 40),

//                               MyTextfield(
//                                 controller: emailController,
//                                 text: "Enter your email",
//                                 errorText: "Please enter your mail",
//                               ),

//                               SizedBox(height: 30),

//                               Text(
//                                 "A code will be sent to your mail",
//                                 style: TextStyle(
//                                   fontSize: 17,
//                                   fontWeight: isTablet
//                                       ? FontWeight.bold
//                                       : FontWeight.w400,
//                                 ),
//                               ),

//                               SizedBox(height: 40),

//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                   isTablet ? 100 : 0,
//                                   0,
//                                   isTablet ? 100 : 0,
//                                   0,
//                                 ),
//                                 child: MyElevatedButton(
//                                   // onPressed: () async {
//                                   //   if (_forgetkey.currentState!.validate()) {
//                                   //     await ref
//                                   //         .read(authViewModelProvider.notifier)
//                                   //         .sendResetEmail(emailController.text);

//                                   //     Navigator.push(
//                                   //       context,
//                                   //       MaterialPageRoute(
//                                   //         builder: (context) =>
//                                   //             ForgetPasswordNewPassword(),
//                                   //       ),
//                                   //     );
//                                   //   }
//                                   // },
//                                   onPressed: () async {
//                                     if (_forgetkey.currentState!.validate()) {
//                                       await ref
//                                           .read(authViewModelProvider.notifier)
//                                           .sendResetEmail(emailController.text);

//                                       final state = ref.read(
//                                         authViewModelProvider,
//                                       );

//                                       if (state.status ==
//                                           AuthStatus.passwordResetEmailSent) {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (context) =>
//                                                 ForgetPasswordNewPassword(),
//                                           ),
//                                         );
//                                       } else if (state.status ==
//                                           AuthStatus.error) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                               state.errorMessage ?? "Error",
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   },

//                                   text: "Next",
//                                   color: const Color.fromARGB(
//                                     255,
//                                     229,
//                                     163,
//                                     32,
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(height: isTablet ? 0 : 10),

//                               MyTextButton(
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => LoginScreen(),
//                                     ),
//                                   );
//                                 },
//                                 text: "Already have an account??",
//                                 textColor: const Color.fromARGB(
//                                   255,
//                                   63,
//                                   124,
//                                   42,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Positioned(
//               top: 10,
//               left: 10,
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.arrow_back,
//                   color: Colors.black,
//                   size: 26,
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => LoginScreen()),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:chautari_kurakani/common/my_snackbar.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_pin_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_field.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final _forgetKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: isTablet ? 40 : 40),

                  // Logo
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

                  // App Name
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

                  // Tagline
                  Text(
                    "Chautarimah Sabai Kura",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: isTablet ? 100 : 60),

                  // Form container
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
                        key: _forgetKey,
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

                              const SizedBox(height: 40),

                              // Email input
                              MyTextfield(
                                controller: emailController,
                                text: "Enter your email",
                                errorText: "Please enter your email",
                              ),

                              const SizedBox(height: 30),

                              Text(
                                "A 6-digit code will be sent to your email",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: isTablet
                                      ? FontWeight.bold
                                      : FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 40),

                              // Next button
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 100 : 0,
                                ),
                                child: MyElevatedButton(
                                  text: "Next",
                                  color: const Color.fromARGB(
                                    255,
                                    229,
                                    163,
                                    32,
                                  ),
                                  onPressed: () async {
                                    if (_forgetKey.currentState!.validate()) {
                                      // Send reset email
                                      await ref
                                          .read(authViewModelProvider.notifier)
                                          .sendResetEmail(emailController.text);
                                      if (!context.mounted) return;

                                      final state = ref.read(
                                        authViewModelProvider,
                                      );

                                      if (state.status ==
                                          AuthStatus.passwordResetEmailSent) {
                                        showMySnackBar(
                                          context: context,
                                          color: Colors.blueGrey,
                                          message:
                                              "Reset code sent to your email.",
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ForgetPasswordPinScreen(
                                                  email: emailController.text
                                                      .trim(),
                                                ),
                                          ),
                                        );
                                      } else if (state.status ==
                                          AuthStatus.error) {
                                        showMySnackBar(
                                          context: context,
                                          message:
                                              state.errorMessage ??
                                              "Error occurred",
                                          color: Colors.red,
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Login button
                              MyTextButton(
                                text: "Already have an account?",
                                textColor: const Color.fromARGB(
                                  255,
                                  63,
                                  124,
                                  42,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
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

            // Back button
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
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
