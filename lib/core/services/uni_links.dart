// import 'dart:async';
// import 'package:uni_links/uni_links.dart';

// class MobileDeepLinkHandler {
//   StreamSubscription? _sub;

//   void init(void Function(String token) onResetPasswordLink) {
//     // App is running and receives a link
//     _sub = uriLinkStream.listen(
//       (Uri? uri) {
//         if (uri != null &&
//             uri.scheme == 'chautarikurakani' &&
//             uri.host == 'reset-password') {
//           final token = uri.queryParameters['token'];
//           if (token != null) onResetPasswordLink(token);
//         }
//       },
//       onError: (err) {
//         print('Error handling deep link: $err');
//       },
//     );

//     // App launched via link
//     handleInitialUri(onResetPasswordLink);
//   }

//   Future<void> handleInitialUri(
//     void Function(String token) onResetPasswordLink,
//   ) async {
//     try {
//       final initialUri = await getInitialUri();
//       if (initialUri != null &&
//           initialUri.scheme == 'chautarikurakani' &&
//           initialUri.host == 'reset-password') {
//         final token = initialUri.queryParameters['token'];
//         if (token != null) onResetPasswordLink(token);
//       }
//     } catch (err) {
//       print('Failed to get initial uri: $err');
//     }
//   }

//   void dispose() {
//     _sub?.cancel();
//   }
// }
import 'dart:async';
import 'package:uni_links/uni_links.dart';

class DeepLinkService {
  StreamSubscription? _sub;

  void init(void Function(String token) onResetPasswordLink) {
    // App is running and receives a link
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null && _isResetPasswordLink(uri)) {
          final token = uri.queryParameters['token'];
          if (token != null && token.isNotEmpty) {
            onResetPasswordLink(token);
          }
        }
      },
      onError: (err) {
        'Error handling deep link: $err';
      },
    );

    // App launched via link
    _handleInitialUri(onResetPasswordLink);
  }

  Future<void> _handleInitialUri(
    void Function(String token) onResetPasswordLink,
  ) async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null && _isResetPasswordLink(initialUri)) {
        final token = initialUri.queryParameters['token'];
        if (token != null && token.isNotEmpty) {
          onResetPasswordLink(token);
        }
      }
    } catch (err) {
      // print('Failed to get initial uri: $err');
      'Failed to get initial uri: $err';
    }
  }

  bool _isResetPasswordLink(Uri uri) {
    final isCustomSchemeLink =
        (uri.scheme == 'chautari' || uri.scheme == 'chautarikurakani') &&
        uri.host == 'reset-password';

    final isResetPath =
        uri.path == '/reset-password' || uri.path == '/reset-password/';

    final isHttpsAppLink =
        uri.scheme == 'https' &&
        uri.host == 'chautari.example.com' &&
        isResetPath;

    return isCustomSchemeLink || isHttpsAppLink;
  }

  void dispose() {
    _sub?.cancel();
  }
}
