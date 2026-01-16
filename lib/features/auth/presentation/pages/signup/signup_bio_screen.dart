import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_coverpicture_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_field.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupBioScreen extends ConsumerStatefulWidget {
  final AuthEntity signupData;

  const SignupBioScreen({super.key, required this.signupData});

  @override
  ConsumerState<SignupBioScreen> createState() => _SignupBioScreenState();
}

class _SignupBioScreenState extends ConsumerState<SignupBioScreen> {
  final TextEditingController bioController = TextEditingController();
  final _signupKey = GlobalKey<FormState>();

  @override
  void dispose() {
    bioController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSignup() async {
    final updatedSignupData = widget.signupData.copyWith(
      bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
    );

    ref
        .read(authViewModelProvider.notifier)
        .register(
          fName: updatedSignupData.fName,
          lName: updatedSignupData.lName,
          email: updatedSignupData.email,
          username: updatedSignupData.username,
          password: updatedSignupData.password!,
          profilePicture: updatedSignupData.profilePicture,
          coverPicture: updatedSignupData.coverPicture,
          bio: updatedSignupData.bio,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // ref.listen<AuthState>(authViewModelProvider, (previous, next) {
    //   if (next.status == AuthStatus.error) {
    //     SnackbarUtils.showError(
    //       context,
    //       next.errorMessage ?? 'Registration Failed',
    //     );
    //   } else if (next.status == AuthStatus.registered) {
    //     SnackbarUtils.showSuccess(context, 'Registration successful! Welcome!');
    //     Navigator.pushReplacement(
    //       context,
    //       MaterialPageRoute(builder: (context) => LoginScreen()),
    //     );
    //   }
    // });
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'Registration Failed',
        );
      } else if (next.status == AuthStatus.registered) {
        // Registration success → go to LoginScreen
        SnackbarUtils.showSuccess(
          context,
          'Registration successful! Please log in.',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });

    double screenWidth = MediaQuery.of(context).size.width;

    bool isTablet = screenWidth > 600;
    return Scaffold(
      backgroundColor: const Color(0xFF76C05D),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: isTablet ? 40 : 40),

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
                      height: isTablet ? 200 : 100,
                      width: isTablet ? 200 : 100,
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
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 28 : 20,
                    ),
                  ),

                  SizedBox(height: isTablet ? 90 : 40),

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
                                  fontSize: isTablet ? 25 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: isTablet ? 15 : 15),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  10,
                                  isTablet ? 300 : 140,
                                  0,
                                ),
                                child: Text(
                                  "Write some fun bio!",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: const Color.fromARGB(
                                      255,
                                      69,
                                      65,
                                      54,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: isTablet ? 50 : 40),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isTablet ? 40 : 0,
                                  0,
                                  isTablet ? 40 : 0,
                                  0,
                                ),
                                child: MyTextfield(
                                  controller: bioController,
                                  text: "Bio",
                                  errorText: '',
                                ),
                              ),

                              SizedBox(height: isTablet ? 50 : 40),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isTablet ? 100 : 0,
                                  0,
                                  isTablet ? 100 : 0,
                                  0,
                                ),
                                child: MyFloatingButton(
                                  onPressed: _handleCompleteSignup,
                                  text: "Finish",
                                  color: const Color.fromARGB(
                                    255,
                                    229,
                                    163,
                                    32,
                                  ),
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
                        builder: (context) => SignupCoverpictureScreen(
                          signupData: widget.signupData,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
