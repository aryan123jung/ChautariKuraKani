import 'dart:io';

import 'package:chautari_kurakani/core/utils/image_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_bio_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_profilepicture_screen.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignupCoverpictureScreen extends StatefulWidget {
  final AuthEntity signupData;

  const SignupCoverpictureScreen({super.key, required this.signupData});

  @override
  State<SignupCoverpictureScreen> createState() =>
      _SignupCoverpictureScreenState();
}

class _SignupCoverpictureScreenState extends State<SignupCoverpictureScreen> {
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
            Column(
              children: [
                SizedBox(height: isTablet ? 40 : 40),

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

                            SizedBox(height: isTablet ? 40 : 15),

                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                0,
                                10,
                                isTablet ? 300 : 140,
                                0,
                              ),
                              child: Text(
                                "Your cover picture.",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: const Color.fromARGB(255, 69, 65, 54),
                                ),
                              ),
                            ),

                            SizedBox(height: isTablet ? 50 : 30),

                            GestureDetector(
                              onTap: _showImageSourceDialog,
                              child: Container(
                                height: isTablet ? 180 : 140,
                                width: isTablet ? 340 : 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20),
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

                            SizedBox(height: isTablet ? 50 : 30),

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
                                        coverPicture: permanentImagePath,
                                      );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupBioScreen(
                                        signupData: updatedSignupData,
                                      ),
                                    ),
                                  );
                                },
                                text: "Next",
                                color: const Color.fromARGB(255, 229, 163, 32),
                              ),
                            ),

                            SizedBox(height: 20),

                            MyTextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignupBioScreen(
                                      signupData: widget.signupData,
                                    ),
                                  ),
                                );
                              },
                              text: "Skip for now",
                              textColor: const Color.fromARGB(255, 63, 124, 42),
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
                      builder: (context) => SignupProfilepictureScreen(
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
    );
  }
}
