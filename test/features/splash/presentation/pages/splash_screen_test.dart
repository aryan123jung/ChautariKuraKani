import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proper mock that implements UserSessionService
class MockUserSessionService implements UserSessionService {
  final bool isLoggedInValue;

  MockUserSessionService(this.isLoggedInValue);

  @override
  bool isLoggedIn() => isLoggedInValue;

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fName,
    required String lName,
    required String username,
    String? profilePicture,
    String? coverPicture,
    String? bio,
  }) async {}

  @override
  String? getCurrentUserBio() => null;

  @override
  String? getCurrentUserCoverPicture() => null;

  @override
  String? getCurrentUserEmail() => null;

  @override
  String? getCurrentUserFirstName() => null;

  @override
  String? getCurrentUserFullName() => null;

  @override
  String? getCurrentUserId() => null;

  @override
  String? getCurrentUserLastName() => null;

  @override
  String? getCurrentUserProfilePicture() => null;

  @override
  String? getCurrentUserUsername() => null;
}

void main() {
  // Keep track of timers to cancel them after each test
  tearDown(() {
    // This ensures no timers are left pending
    // The test framework will handle this automatically if we dispose widgets properly
  });

  group('SplashScreen Widget Tests', () {
    testWidgets('Should display logo and app name', (
      WidgetTester tester,
    ) async {
      // Build our widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSessionServiceProvider.overrideWithValue(
              MockUserSessionService(false),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Verify the logo is displayed
      expect(find.byType(Image), findsOneWidget);

      // Verify app name is displayed
      expect(find.text('ChautariKuraKani'), findsOneWidget);
      expect(find.text('Chautarimah Sabai Kura'), findsOneWidget);
    });

    testWidgets('Should show green background', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSessionServiceProvider.overrideWithValue(
              MockUserSessionService(false),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Find Scaffold and check background color
      final scaffoldFinder = find.byType(Scaffold);
      final scaffoldWidget = tester.widget<Scaffold>(scaffoldFinder);

      // Background color should be green (0xFF76C05D)
      expect((scaffoldWidget.backgroundColor as Color), 0xFF76C05D);
    });

    testWidgets('Should have safe area', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSessionServiceProvider.overrideWithValue(
              MockUserSessionService(false),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Verify SafeArea is present
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('Should have scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSessionServiceProvider.overrideWithValue(
              MockUserSessionService(false),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Verify SingleChildScrollView is present (prevents overflow)
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Should display correct layout structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSessionServiceProvider.overrideWithValue(
              MockUserSessionService(false),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Verify the widget hierarchy
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);

      // There might be multiple ScaleTransition widgets (from logo and maybe Lottie)
      // So use findsAtLeast instead of findsOneWidget
      expect(find.byType(ScaleTransition), findsAtLeast(1));
    });

    testWidgets('Should handle timer without errors', (
      WidgetTester tester,
    ) async {
      // This test verifies the timer doesn't cause issues
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userSessionServiceProvider.overrideWithValue(
              MockUserSessionService(false),
            ),
          ],
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      // Pump a small amount of time to allow timer to start
      await tester.pump(const Duration(milliseconds: 100));

      // Verify widget still renders
      expect(find.text('ChautariKuraKani'), findsOneWidget);

      // Clean up by pumping enough time for timer to complete
      // This prevents the "pending timer" error
      await tester.pump(const Duration(seconds: 4));
    });
  });

  // Test that specifically handles the timer disposal
  testWidgets('SplashScreen disposes properly', (WidgetTester tester) async {
    // Create a completer to track when dispose is called
    // bool disposed = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(
            MockUserSessionService(false),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              // Wrap in StatefulBuilder to track disposal
              return StatefulBuilder(
                builder: (context, setState) {
                  return const SplashScreen();
                },
              );
            },
          ),
        ),
      ),
    );

    // Pump a bit of time
    await tester.pump(const Duration(milliseconds: 100));

    // Navigate away to trigger dispose
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(
            MockUserSessionService(false),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: Center(child: Text('Next Screen'))),
        ),
      ),
    );

    // Pump enough time for any pending timers
    await tester.pump(const Duration(seconds: 4));

    // Should not have any pending timer errors
    expect(tester.takeException(), isNull);
  });
}
