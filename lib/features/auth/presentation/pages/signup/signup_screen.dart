// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_profilepicture_screen.dart';
// import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
// import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
// import 'package:chautari_kurakani/core/widgets/my_text_field.dart';
// import 'package:flutter/material.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _signupForm = GlobalKey<FormState>();

//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();

//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     bool isTablet = screenWidth > 600;

//     return Scaffold(
//       backgroundColor: const Color(0xFF76C05D),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: isTablet ? 40 : 40),

//               // Image.asset('assets/images/white_half_logo.png',height: 100,width: 100,),
//               Container(
//                 // height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.2),
//                       blurRadius: 26,
//                       spreadRadius: 1,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Image.asset(
//                   'assets/images/white_half_logo.png',
//                   height: isTablet ? 200 : 100,
//                   width: isTablet ? 200 : 100,
//                   // width: 100,
//                 ),
//               ),

//               SizedBox(height: isTablet ? 30 : 20),

//               Text(
//                 "ChautariKuraKani",
//                 style: TextStyle(
//                   fontSize: isTablet ? 70 : 40,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black.withValues(alpha: 0.2),
//                       blurRadius: 15,
//                       offset: Offset(2, 3),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: isTablet ? 0 : 5),

//               Text(
//                 "Chautarimah Sabai Kura",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: isTablet ? 28 : 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               SizedBox(height: isTablet ? 90 : 40),

//               Padding(
//                 // padding: const EdgeInsets.all(13.0),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isTablet ? screenWidth * 0.2 : 13,
//                 ),
//                 child: Container(
//                   // height: 200,
//                   // width: double.infinity,
//                   width: isTablet ? screenWidth * 0.6 : double.infinity,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE3E3E3),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.3),
//                         blurRadius: 12,
//                         spreadRadius: 2,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Form(
//                     key: _signupForm,

//                     child: Padding(
//                       padding: EdgeInsets.fromLTRB(
//                         isTablet ? 45 : 15,
//                         20,
//                         isTablet ? 45 : 15,
//                         0,
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             "Create an account",
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(height: 20),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: MyTextfield(
//                                   controller: firstNameController,
//                                   text: "First Name",
//                                   hintText: "First Name",
//                                   errorText: "Please enter your first name",
//                                 ),
//                               ),

//                               SizedBox(width: 10),

//                               Expanded(
//                                 child: MyTextfield(
//                                   controller: lastNameController,
//                                   text: "Last Name",
//                                   hintText: "Last Name",
//                                   errorText: "Please enter your last name",
//                                 ),
//                               ),
//                             ],
//                           ),

//                           SizedBox(height: 10),

//                           MyTextfield(
//                             controller: emailController,
//                             text: "Email",
//                             hintText: "Email",
//                             errorText: "Please enter your email",
//                             prefixIcon: Icons.email,
//                           ),

//                           SizedBox(height: 10),

//                           MyTextfield(
//                             controller: passwordController,
//                             text: "Password",
//                             hintText: "Password",
//                             errorText: "Please enter your password",
//                             prefixIcon: Icons.lock,
//                             isPassword: true,
//                           ),

//                           SizedBox(height: 10),

//                           MyTextfield(
//                             controller: confirmPasswordController,
//                             text: "Confirm Password",
//                             hintText: "Confirm Password",
//                             errorText: "Please enter your password",
//                             prefixIcon: Icons.lock,
//                             isPassword: true,
//                           ),

//                           SizedBox(height: 30),

//                           Padding(
//                             padding: EdgeInsets.fromLTRB(
//                               isTablet ? 100 : 0,
//                               0,
//                               isTablet ? 100 : 0,
//                               0,
//                             ),
//                             child: MyFloatingButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         SignupProfilepictureScreen(),
//                                   ),
//                                 );
//                               },
//                               text: "Next",
//                               color: const Color.fromARGB(255, 229, 163, 32),
//                             ),
//                           ),

//                           SizedBox(height: 20),

//                           MyTextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => LoginScreen(),
//                                 ),
//                               );
//                             },
//                             text: "Already have an account??",
//                             textColor: const Color.fromARGB(255, 63, 124, 42),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_profilepicture_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _signupForm = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_signupForm.currentState!.validate()) {
      ref
          .read(authViewModelProvider.notifier)
          .register(
            fName: _firstNameController.text,
            lName: _lastNameController.text,
            email: _emailController.text,
            username:
                "${_firstNameController.text.trim()}${_lastNameController.text.trim()}",
            password: _passwordController.text,
          );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Registration Failed',
        );
      } else if (next.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(context, 'Registration successful!');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoginScreen()),
        // );
        AppRoutes.pushReplacement(context, LoginScreen());
      }
    });

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
                                child: TextFormField(
                                  controller: _firstNameController,
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    hintText: 'Enter your first name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    if (value.length < 3) {
                                      return 'Name must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                  // text: "First Name",
                                  // hintText: "First Name",
                                  // errorText: "Please enter your first name",
                                ),
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    hintText: 'Enter your last name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    if (value.length < 3) {
                                      return 'Name must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                  // text: "Last Name",
                                  // hintText: "Last Name",
                                  // errorText: "Please enter your last name",
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              // Basic email validation
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 10),

                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: 10),

                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
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
                              onPressed: _handleSignup,
                              text: "Next",
                              color: const Color.fromARGB(255, 229, 163, 32),
                              isLoading: authState.status == AuthStatus.loading,
                            ),
                          ),

                          SizedBox(height: 20),

                          MyTextButton(
                            onPressed: _navigateToLogin,
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
