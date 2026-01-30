// import 'dart:io';

// import 'package:chautari_kurakani/core/api/api_endpoints.dart';
// import 'package:chautari_kurakani/core/utils/image_utils.dart';
// import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
// import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';
// import 'package:chautari_kurakani/core/widgets/my_text_button.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/signup/signup_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';

// class SignupProfilepictureScreen extends ConsumerStatefulWidget {
//   final AuthEntity signupData;

//   const SignupProfilepictureScreen({super.key, required this.signupData});

//   @override
//   ConsumerState<SignupProfilepictureScreen> createState() =>
//       _SignupProfilepictureScreenState();
// }

// class _SignupProfilepictureScreenState
//     extends ConsumerState<SignupProfilepictureScreen> {
//   final ImagePicker _picker = ImagePicker();
//   File? _selectedImage;
//   final _signupKey = GlobalKey<FormState>();

//   Future<void> _pickImage(ImageSource source, {required bool isProfile}) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 1000,
//         maxHeight: 1000,
//         imageQuality: 85,
//       );

//       if (pickedFile == null) return;

//       final imageFile = File(pickedFile.path);

//       setState(() {
//         if (isProfile) {
//           _selectedImage = File(pickedFile.path);
//         }
//       });

//       if (isProfile) {
//         await ref
//             .read(authViewModelProvider.notifier)
//             .uploadProfileImage(imageFile);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       SnackbarUtils.showError(context, 'Failed to pick image');
//     }
//   }

//   void _showImageSourceDialog({required bool isProfile}) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take Photo'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera, isProfile: isProfile);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery, isProfile: isProfile);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ✅ FINAL REGISTER (IMAGE OPTIONAL)
//   Future<void> _handleCompleteSignup() async {
//     String? permanentImagePath;

//     if (_selectedImage != null) {
//       permanentImagePath = await ImageUtils.saveImagePermanently(
//         _selectedImage!,
//       );
//     }

//     final updatedSignupData = widget.signupData.copyWith(
//       profilePicture: permanentImagePath,
//     );

//     ref
//         .read(authViewModelProvider.notifier)
//         .register(
//           fName: updatedSignupData.fName,
//           lName: updatedSignupData.lName,
//           email: updatedSignupData.email,
//           username: updatedSignupData.username,
//           password: updatedSignupData.password!,
//           profilePicture: updatedSignupData.profilePicture,
//           // coverPicture: updatedSignupData.coverPicture,
//           // bio: updatedSignupData.bio,
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     bool isTablet = screenWidth > 600;
//     final authState = ref.watch(authViewModelProvider);

//     ref.listen<AuthState>(authViewModelProvider, (prev, next) {
//       if (next.status == AuthStatus.error) {
//         SnackbarUtils.showError(
//           context,
//           next.errorMessage ?? 'Registration failed',
//         );
//       } else if (next.status == AuthStatus.registered) {
//         SnackbarUtils.showSuccess(
//           context,
//           'Registration successful! Please log in.',
//         );
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginScreen()),
//         );
//       }
//     });

//     if (authState.status == AuthStatus.loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFF76C05D),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(height: isTablet ? 40 : 40),

//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.2),
//                         blurRadius: 26,
//                         spreadRadius: 1,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Image.asset(
//                     'assets/images/white_half_logo.png',
//                     height: isTablet ? 200 : 100,
//                     width: isTablet ? 200 : 100,
//                   ),
//                 ),

//                 SizedBox(height: isTablet ? 30 : 20),

//                 Text(
//                   "ChautariKuraKani",
//                   style: TextStyle(
//                     fontSize: isTablet ? 70 : 40,
//                     fontWeight: FontWeight.bold,
//                     shadows: [
//                       Shadow(
//                         color: Colors.black.withValues(alpha: 0.2),
//                         blurRadius: 15,
//                         offset: Offset(2, 3),
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: isTablet ? 0 : 5),

//                 Text(
//                   "Chautarimah Sabai Kura",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: isTablet ? 28 : 20,
//                   ),
//                 ),

//                 SizedBox(height: isTablet ? 90 : 40),

//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isTablet ? screenWidth * 0.2 : 13,
//                   ),
//                   child: Container(
//                     width: isTablet ? screenWidth * 0.6 : double.infinity,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE3E3E3),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha: 0.3),
//                           blurRadius: 12,
//                           spreadRadius: 2,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Form(
//                       key: _signupKey,
//                       child: Padding(
//                         padding: EdgeInsets.fromLTRB(
//                           isTablet ? 45 : 15,
//                           20,
//                           isTablet ? 45 : 15,
//                           0,
//                         ),
//                         child: Column(
//                           children: [
//                             Text(
//                               "Add profile picture (optional)",
//                               style: TextStyle(
//                                 fontSize: isTablet ? 25 : 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),

//                             SizedBox(height: isTablet ? 40 : 15),

//                             // GestureDetector(
//                             //   onTap: _showImageSourceDialog(isProfile: true),
//                             //   child: Container(
//                             //     height: isTablet ? 180 : 140,
//                             //     width: isTablet ? 180 : 140,
//                             //     decoration: BoxDecoration(
//                             //       shape: BoxShape.circle,
//                             //       color: const Color(0xFFE3E3E3),
//                             //       image: _selectedImage != null
//                             //           ? DecorationImage(
//                             //               image: FileImage(_selectedImage!),
//                             //               fit: BoxFit.cover,
//                             //             )
//                             //           : null,
//                             //     ),
//                             //     child: _selectedImage == null
//                             //         ? Icon(
//                             //             Icons.camera_alt,
//                             //             size: isTablet ? 60 : 50,
//                             //           )
//                             //         : null,
//                             //   ),
//                             // ),
//                             GestureDetector(
//                               onTap: () =>
//                                   _showImageSourceDialog(isProfile: true),
//                               child: Container(
//                                 height: 140,
//                                 width: 140,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: const Color(0xFFE3E3E3),
//                                   image: _selectedImage != null
//                                       ? DecorationImage(
//                                           image: FileImage(_selectedImage!),
//                                           fit: BoxFit.cover,
//                                         )
//                                       : (widget.signupData.profilePicture !=
//                                                 null &&
//                                             widget
//                                                 .signupData
//                                                 .profilePicture!
//                                                 .isNotEmpty)
//                                       ? DecorationImage(
//                                           image: NetworkImage(
//                                             ApiEndpoints.profileImageUrl(
//                                               widget.signupData.profilePicture!,
//                                             ),
//                                           ),
//                                           fit: BoxFit.cover,
//                                         )
//                                       : null,
//                                 ),
//                                 child:
//                                     _selectedImage == null &&
//                                         (widget.signupData.profilePicture ==
//                                                 null ||
//                                             widget
//                                                 .signupData
//                                                 .profilePicture!
//                                                 .isEmpty)
//                                     ? const Icon(Icons.person, size: 50)
//                                     : null,
//                               ),
//                             ),

//                             SizedBox(height: isTablet ? 40 : 30),

//                             MyFloatingButton(
//                               onPressed: _handleCompleteSignup,
//                               text: "Register",
//                               color: const Color.fromARGB(255, 229, 163, 32),
//                             ),

//                             SizedBox(height: 20),

//                             MyTextButton(
//                               onPressed: _handleCompleteSignup,
//                               text: "Skip for now",
//                               textColor: const Color.fromARGB(255, 63, 124, 42),
//                             ),

//                             SizedBox(height: 30),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
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
//                     MaterialPageRoute(builder: (_) => SignupScreen()),
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
