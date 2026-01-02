// import 'dart:io';
// import 'package:chautari_kurakani/core/routes/app_routes.dart';
// import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
// import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
// import 'package:chautari_kurakani/core/utils/snackbar_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ProfileScreen extends ConsumerWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);
//     final user = authState.authEntity;

//     return Scaffold(
//       body: user == null
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     color: Colors.grey[300],
//                     child:
//                         user.coverPicture != null &&
//                             user.coverPicture!.isNotEmpty
//                         ? Image.file(
//                             File(user.coverPicture!),
//                             fit: BoxFit.cover,
//                           )
//                         : const Center(
//                             child: Icon(
//                               Icons.image,
//                               size: 50,
//                               color: Colors.grey,
//                             ),
//                           ),
//                   ),

//                   Transform.translate(
//                     offset: const Offset(0, -50),
//                     child: Center(
//                       child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white,
//                           border: Border.all(color: Colors.white, width: 4),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.2),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                           image:
//                               user.profilePicture != null &&
//                                   user.profilePicture!.isNotEmpty
//                               ? DecorationImage(
//                                   image: FileImage(File(user.profilePicture!)),
//                                   fit: BoxFit.cover,
//                                 )
//                               : null,
//                         ),
//                         child:
//                             (user.profilePicture == null ||
//                                 user.profilePicture!.isEmpty)
//                             ? const Icon(
//                                 Icons.person,
//                                 size: 50,
//                                 color: Colors.grey,
//                               )
//                             : null,
//                       ),
//                     ),
//                   ),

//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
//                     child: Column(
//                       children: [
//                         Text(
//                           '${user.fName} ${user.lName}',
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),

//                         const SizedBox(height: 8),

//                         Text(
//                           '@${user.username}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         Text(
//                           user.bio != null && user.bio!.isNotEmpty
//                               ? user.bio!
//                               : 'No bio available.',
//                           style: const TextStyle(fontSize: 16),
//                         ),

//                         const SizedBox(height: 30),

//                         SizedBox(
//                           width: 200,
//                           child: ElevatedButton(
//                             onPressed: () => _showLogoutDialog(context, ref),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text(
//                               "Logout",
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Text(
//           'Logout',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () async {
//               // Navigator.pop(context);

//               // // Perform logout
//               // await ref.read(authViewModelProvider.notifier).logout();
//               // // Show confirmation snackbar
//               // SnackbarUtils.showSuccess(context, 'Logged out successfully!');

//               // Navigate to Login screen and remove all previous routes
//               AppRoutes.pushAndRemoveUntil(context, const LoginScreen());
//             },
//             child: const Text(
//               'Logout',
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.unauthenticated) {
        // Navigate to login screen and clear all routes
        // Navigator.of(
        //   context,
        // ).pushNamedAndRemoveUntil('/login', (route) => false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: _buildBody(context, ref, authState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, AuthState authState) {
    if (authState.status == AuthStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authState.authEntity == null) {
      // return const Center(child: Text('No user data available'));
      // return LoginScreen();
      Center(child: CircularProgressIndicator());
    }

    final user = authState.authEntity!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: user.coverPicture != null && user.coverPicture!.isNotEmpty
                ? Image.file(File(user.coverPicture!), fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
          ),

          Transform.translate(
            offset: const Offset(0, -50),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image:
                      user.profilePicture != null &&
                          user.profilePicture!.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(user.profilePicture!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    (user.profilePicture == null ||
                        user.profilePicture!.isEmpty)
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            '${user.fName} ${user.lName}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Text(
            '@${user.username}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),

          Text(
            user.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.bio!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: authState.status == AuthStatus.loading
                  ? null
                  : () => _showLogoutDialog(context, ref),
              icon: authState.status == AuthStatus.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.logout),
              label: Text(
                authState.status == AuthStatus.loading
                    ? 'Logging out...'
                    : 'Logout',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(AuthEntity user) {
    final initials = '${user.fName[0]}${user.lName[0]}'.toUpperCase();
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authViewModelProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
