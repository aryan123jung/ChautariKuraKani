// import 'dart:io';

// import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_coverpicture_screen.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/signup_data.dart';
// import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
// import 'package:chautari_kurakani/core/utils/image_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class SignupProfilepictureScreen extends StatefulWidget {
//   final SignupData signupData;

//   const SignupProfilepictureScreen({super.key, required this.signupData});

//   @override
//   State<SignupProfilepictureScreen> createState() =>
//       _SignupProfilepictureScreenState();
// }

// class _SignupProfilepictureScreenState
//     extends State<SignupProfilepictureScreen> {
//   final _signupKey = GlobalKey<FormState>();

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
//                           offset: Offset(0, 4),
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
//                           offset: Offset(2, 3),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: isTablet ? 0 : 5),

//                   Text(
//                     "Chautarimah Sabai Kura",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                       fontSize: isTablet ? 28 : 20,
//                     ),
//                   ),

//                   SizedBox(height: isTablet ? 90 : 40),

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
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Form(
//                         key: _signupKey,
//                         child: Padding(
//                           padding: EdgeInsets.fromLTRB(
//                             isTablet ? 45 : 15,
//                             20,
//                             isTablet ? 45 : 15,
//                             0,
//                           ),
//                           child: Column(
//                             children: [
//                               Text(
//                                 "Create your profile",
//                                 style: TextStyle(
//                                   fontSize: isTablet ? 25 : 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),

//                               SizedBox(height: isTablet ? 40 : 15),

//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                   0,
//                                   10,
//                                   isTablet ? 300 : 140,
//                                   0,
//                                 ),
//                                 child: Text(
//                                   "Your profile picture.",
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.w400,
//                                     color: const Color.fromARGB(
//                                       255,
//                                       69,
//                                       65,
//                                       54,
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(height: isTablet ? 50 : 30),

//                               Container(
//                                 height: isTablet ? 180 : 140,
//                                 width: isTablet ? 180 : 140,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: const Color(0xFFE3E3E3),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withValues(
//                                         alpha: 0.25,
//                                       ),
//                                       blurRadius: 12,
//                                       spreadRadius: 1,
//                                       offset: Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Icon(
//                                   Icons.camera_alt,
//                                   size: isTablet ? 60 : 50,
//                                   color: const Color.fromARGB(
//                                     255,
//                                     120,
//                                     120,
//                                     120,
//                                   ),
//                                 ),
//                               ),

//                               SizedBox(height: isTablet ? 60 : 40),

//                               Text(
//                                 "Tap above to choose image",
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),

//                               SizedBox(height: isTablet ? 50 : 30),

//                               Padding(
//                                 padding: EdgeInsets.fromLTRB(
//                                   isTablet ? 100 : 0,
//                                   0,
//                                   isTablet ? 100 : 0,
//                                   0,
//                                 ),
//                                 child: MyFloatingButton(
//                                   onPressed: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) =>
//                                             SignupCoverpictureScreen(),
//                                       ),
//                                     );
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

//                               SizedBox(height: isTablet ? 30 : 30),
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
//                   size: 30,
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SignupScreen()),
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

import 'dart:io';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_coverpicture_screen.dart';
import 'package:chautari_kurakani/core/utils/image_utils.dart';

class SignupProfilepictureScreen extends StatefulWidget {
  final AuthEntity signupData;

  const SignupProfilepictureScreen({super.key, required this.signupData});

  @override
  State<SignupProfilepictureScreen> createState() =>
      _SignupProfilepictureScreenState();
}

class _SignupProfilepictureScreenState
    extends State<SignupProfilepictureScreen> {
  final _signupKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

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
                                "Add profile picture (optional)",
                                style: TextStyle(
                                  fontSize: isTablet ? 25 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: isTablet ? 40 : 15),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  10,
                                  isTablet ? 300 : 140,
                                  0,
                                ),
                                child: Text(
                                  "Choose a profile picture",
                                  style: TextStyle(
                                    fontSize: 18,
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

                              SizedBox(height: isTablet ? 50 : 30),

                              GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  height: isTablet ? 180 : 140,
                                  width: isTablet ? 180 : 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFE3E3E3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                    image: _selectedImage != null
                                        ? DecorationImage(
                                            image: FileImage(_selectedImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _selectedImage == null
                                      ? Icon(
                                          Icons.camera_alt,
                                          size: isTablet ? 60 : 50,
                                          color: const Color.fromARGB(
                                            255,
                                            120,
                                            120,
                                            120,
                                          ),
                                        )
                                      : null,
                                ),
                              ),

                              SizedBox(height: isTablet ? 60 : 40),

                              Text(
                                _selectedImage != null
                                    ? "Tap to change image (optional)"
                                    : "Tap above to choose image (optional)",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              if (_selectedImage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Selected: ${_selectedImage!.path.split('/').last}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              SizedBox(height: isTablet ? 30 : 30),

                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  isTablet ? 100 : 0,
                                  0,
                                  isTablet ? 100 : 0,
                                  0,
                                ),
                                child: MyFloatingButton(
                                  onPressed: () async {
                                    String? permanentImagePath;
                                    if (_selectedImage != null) {
                                      permanentImagePath =
                                          await ImageUtils.saveImagePermanently(
                                            _selectedImage!,
                                          );
                                    }

                                    final updatedSignupData = widget.signupData
                                        .copyWith(
                                          profilePicture: permanentImagePath,
                                        );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SignupCoverpictureScreen(
                                              signupData: updatedSignupData,
                                            ),
                                      ),
                                    );
                                  },
                                  text: "Next",
                                  color: const Color.fromARGB(
                                    255,
                                    229,
                                    163,
                                    32,
                                  ),
                                ),
                              ),

                              SizedBox(height: 20),

                              MyTextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SignupCoverpictureScreen(
                                            signupData: widget.signupData,
                                          ),
                                    ),
                                  );
                                },
                                text: "Skip for now",
                                textColor: const Color.fromARGB(
                                  255,
                                  63,
                                  124,
                                  42,
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
                    MaterialPageRoute(builder: (context) => SignupScreen()),
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
