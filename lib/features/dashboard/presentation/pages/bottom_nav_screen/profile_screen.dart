// import 'package:chautari_kurakani/core/routes/app_routes.dart';
// import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
// import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ProfileScreen extends ConsumerStatefulWidget {
//   final AuthEntity userEntity;
//   const ProfileScreen({super.key, required this.userEntity});

//   @override
//   ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends ConsumerState<ProfileScreen> {
//   Future<void> _handleLogout() async {
//     await ref.read(authViewModelProvider.notifier).logout();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     // 🔔 Listen for logout & redirect
//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.status == AuthStatus.unauthenticated) {
//         SnackbarUtils.showSuccess(context, "Logged out successfully");
//         AppRoutes.pushReplacement(context, const LoginScreen());
//       } else if (next.status == AuthStatus.error && next.errorMessage != null) {
//         SnackbarUtils.showError(
//           context,
//           next.errorMessage ?? 'An error occurred',
//         );
//       }
//     });

//     if (authState.status == AuthStatus.loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     // if (authState.authEntity == null) {
//     //   return const Scaffold(body: Center(child: Text("No user data found")));
//     // }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Profile'), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [

//             // 📧 Email
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: Colors.grey.shade100,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Email',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     widget.userEntity.email,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),

//             // 🚪 Logout button
//             ElevatedButton(
//               onPressed: _handleLogout,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: authState.status == AuthStatus.loading
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : const Text(
//                       'Logout',
//                       style: TextStyle(fontSize: 16, color: Colors.white),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:chautari_kurakani/core/routes/app_routes.dart';
import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final AuthEntity userEntity;
  const ProfileScreen({super.key, required this.userEntity});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedProfileImage;
  File? _selectedCoverImage;

  Future<void> _pickImage(ImageSource source, {required bool isProfile}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (isProfile) {
            _selectedProfileImage = File(pickedFile.path);
          } else {
            _selectedCoverImage = File(pickedFile.path);
          }
          // _selectedProfileImage = File(pickedFile.path);
          // _selectedCoverImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, "Failed to pick image: $e");
    }
  }

  void _showImageSourceDialog({required bool isProfile}) {
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
                // _pickProfileImage(ImageSource.camera);
                // _pickCoverImage(ImageSource.camera);
                _pickImage(ImageSource.camera, isProfile: isProfile);
              },
            ),

            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, isProfile: isProfile);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    await ref.read(authViewModelProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // 🔔 Listen for logout & redirect
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        SnackbarUtils.showSuccess(context, "Logged out successfully");
        AppRoutes.pushReplacement(context, const LoginScreen());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(
          context,
          next.errorMessage ?? 'An error occurred',
        );
      }
    });

    if (authState.status == AuthStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // if (authState.authEntity == null) {
    //   return const Scaffold(body: Center(child: Text("No user data found")));
    // }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _showImageSourceDialog(isProfile: false),
              child: Container(
                height: 140,
                width: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFE3E3E3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: _selectedCoverImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedCoverImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedCoverImage == null
                    ? Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: const Color.fromARGB(255, 120, 120, 120),
                      )
                    : null,
              ),
            ),

            SizedBox(height: 40),

            GestureDetector(
              onTap: () => _showImageSourceDialog(isProfile: true),
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE3E3E3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: _selectedProfileImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedProfileImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedProfileImage == null
                    ? Icon(
                        Icons.person_2_rounded,
                        size: 50,
                        color: const Color.fromARGB(255, 120, 120, 120),
                      )
                    : null,
              ),
            ),

            SizedBox(height: 20),

            // 📧 Email
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.userEntity.email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🚪 Logout button
            ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: authState.status == AuthStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
