// side_navigation_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SideNavigationDrawer extends ConsumerWidget {
  final String fullName;
  final String email;
  final String? profilePicture;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onPrivacyPolicy;

  const SideNavigationDrawer({
    super.key,
    required this.fullName,
    required this.email,
    this.profilePicture,
    required this.onLogout,
    required this.onEditProfile,
    required this.onSettings,
    required this.onHelp,
    required this.onPrivacyPolicy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Container(
        color: isDark ? Colors.grey[900] : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header with user info
            UserAccountsDrawerHeader(
              accountName: Text(
                fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(email),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  // colors: [Colors.blue.shade400, Colors.blue.shade700],
                  colors: [Color(0xFF76C05D), Color(0xFF4a9a3a)],
                ),
              ),
            ),

            // Profile Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Colors.blue.shade700),
              ),
              title: const Text('My Profile'),
              subtitle: const Text('View and edit your profile'),
              onTap: () {
                Navigator.pop(context);
                // Scroll to top of profile
              },
            ),
            const Divider(),

            // Edit Profile
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Colors.green.shade700),
              ),
              title: const Text('Edit Profile'),
              subtitle: const Text('Update your information'),
              onTap: () {
                Navigator.pop(context);
                onEditProfile();
              },
            ),

            // Settings
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.settings, color: Colors.orange.shade700),
              ),
              title: const Text('Settings'),
              subtitle: const Text('App preferences and settings'),
              onTap: () {
                Navigator.pop(context);
                onSettings();
              },
            ),

            // Help
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.help, color: Colors.purple.shade700),
              ),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help using the app'),
              onTap: () {
                Navigator.pop(context);
                onHelp();
              },
            ),

            // Privacy Policy
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.privacy_tip, color: Colors.teal.shade700),
              ),
              title: const Text('Privacy Policy'),
              subtitle: const Text('Read our privacy policy'),
              onTap: () {
                Navigator.pop(context);
                onPrivacyPolicy();
              },
            ),
            const Divider(),

            // Logout
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, color: Colors.red.shade700),
              ),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Sign out from your account'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
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
