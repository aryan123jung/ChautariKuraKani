import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

// class UserSessionService {
//   final SharedPreferences _prefs;

//   // Keys for storing user data
//   static const String _keyIsLoggedIn = 'is_logged_in';
//   static const String _keyUserId = 'user_id';
//   static const String _keyUserEmail = 'user_email';
//   static const String _keyUserFirstName = 'user_first_name';
//   static const String _keyUserLastName = 'user_last_name';
//   static const String _keyUserUsername = 'user_username';
//   static const String _keyUserProfilePicture = 'user_profile_picture';
//   static const String _keyUserCoverPicture = 'user_cover_picture';
//   static const String _keyUserBio = 'user_bio';

//   UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

//   // Save user session after login
//   Future<void> saveUserSession({
//     required String userId,
//     required String email,
//     required String fName,
//     required String lName,
//     required String username,
//     String? profilePicture,
//     String? cooverPicture,
//     String? bio,
//   }) async {
//     await _prefs.setBool(_keyIsLoggedIn, true);
//     await _prefs.setString(_keyUserId, userId);
//     await _prefs.setString(_keyUserEmail, email);
//     await _prefs.setString(_keyUserFirstName, fName);
//     await _prefs.setString(_keyUserLastName, lName);
//     await _prefs.setString(_keyUserUsername, username);
//     if (profilePicture != null) {
//       await _prefs.setString(_keyUserProfilePicture, profilePicture);
//     }
//     if (cooverPicture != null) {
//       await _prefs.setString(_keyUserCoverPicture, cooverPicture);
//     }
//     if (bio != null) {
//       await _prefs.setString(_keyUserBio, bio);
//     }
//   }
//   // Check if user is logged in
//   bool isLoggedIn() {
//     return _prefs.getBool(_keyIsLoggedIn) ?? false;
//   }

//   // Get current user ID
//   String? getCurrentUserId() {
//     return _prefs.getString(_keyUserId);
//   }

//   // Get current user email
//   String? getCurrentUserEmail() {
//     return _prefs.getString(_keyUserEmail);
//   }

//   // Get current user full name
//   String? getCurrentUserFullName() {
//     return _prefs.getString(_keyUserFirstName)! + ' ' + (_prefs.getString(_keyUserLastName) ?? '');
//   }

//   // Get current user username
//   String? getCurrentUserUsername() {
//     return _prefs.getString(_keyUserUsername);
//   }

//   // Get current user phone number
//   // String? getCurrentUserPhoneNumber() {
//   //   return _prefs.getString(_keyUserPhoneNumber);
//   // }

//   // Get current user profile picture
//   String? getCurrentUserProfilePicture() {
//     return _prefs.getString(_keyUserProfilePicture);
//   }

//   // Get current user cover picture
//   String? getCurrentUserCoverPicture() {
//     return _prefs.getString(_keyUserCoverPicture);
//   }

//   // Get current user bio
//   String? getCurrentUserBio() {
//     return _prefs.getString(_keyUserBio);
//   }

//   // Clear user session (logout)
//   Future<void> clearSession() async {
//     await _prefs.remove(_keyIsLoggedIn);
//     await _prefs.remove(_keyUserId);
//     await _prefs.remove(_keyUserEmail);
//     await _prefs.remove(_keyUserFirstName);
//     await _prefs.remove(_keyUserLastName);
//     await _prefs.remove(_keyUserUsername);
//     await _prefs.remove(_keyUserProfilePicture);
//     await _prefs.remove(_keyUserCoverPicture);
//     await _prefs.remove(_keyUserBio);
//   }
// }
class UserSessionService {
  final SharedPreferences _prefs;

  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';
  static const _keyUserFirstName = 'user_first_name';
  static const _keyUserLastName = 'user_last_name';
  static const _keyUserUsername = 'user_username';
  static const _keyUserProfilePicture = 'user_profile_picture';
  static const _keyUserCoverPicture = 'user_cover_picture';
  static const _keyUserBio = 'user_bio';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fName,
    required String lName,
    required String username,
    String? profilePicture,
    String? coverPicture,
    String? bio,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFirstName, fName);
    await _prefs.setString(_keyUserLastName, lName);
    await _prefs.setString(_keyUserUsername, username);

    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
    if (coverPicture != null) {
      await _prefs.setString(_keyUserCoverPicture, coverPicture);
    }
    if (bio != null) {
      await _prefs.setString(_keyUserBio, bio);
    }
  }

  /// ✅ CHECK LOGIN
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// ✅ GET USER ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  //Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  //Get current user first name
  String? getCurrentUserFirstName() {
    return _prefs.getString(_keyUserFirstName);
  }

  //Get current user last name
  String? getCurrentUserLastName() {
    return _prefs.getString(_keyUserLastName);
  }

  //Get current user username
  String? getCurrentUserUsername() {
    return _prefs.getString(_keyUserUsername);
  }

  //Get current user profile picture
  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  //Get current user cover picture
  String? getCurrentUserCoverPicture() {
    return _prefs.getString(_keyUserCoverPicture);
  }

  //Get current user bio
  String? getCurrentUserBio() {
    return _prefs.getString(_keyUserBio);
  }

  /// ✅ SAFE FULL NAME
  String? getCurrentUserFullName() {
    final fName = _prefs.getString(_keyUserFirstName);
    final lName = _prefs.getString(_keyUserLastName);
    if (fName == null) return null;
    return '$fName ${lName ?? ''}';
  }

  /// ✅ LOGOUT
  // Future<void> clearSession() async {
  //   await _prefs.clear();
  // }
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFirstName);
    await _prefs.remove(_keyUserLastName);
    await _prefs.remove(_keyUserUsername);
    await _prefs.remove(_keyUserProfilePicture);
    await _prefs.remove(_keyUserCoverPicture);
    await _prefs.remove(_keyUserBio);
  }
}
