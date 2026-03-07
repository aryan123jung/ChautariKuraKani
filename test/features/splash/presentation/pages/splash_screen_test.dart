import 'package:chautari_kurakani/core/services/storage/user_session_service.dart';
import 'package:chautari_kurakani/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockUserSessionService implements UserSessionService {
  MockUserSessionService(this.isLoggedInValue);
  final bool isLoggedInValue;

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
  Widget buildTestApp({required bool isLoggedIn}) {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(
          MockUserSessionService(isLoggedIn),
        ),
      ],
      child: const MaterialApp(home: SplashScreen()),
    );
  }

  Future<void> flushSplashTimer(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  Future<void> setLargeScreen(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 2600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('SplashScreen Widget Tests', () {
    testWidgets('renders app title and subtitle', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(buildTestApp(isLoggedIn: false));
      expect(find.text('ChautariKuraKani'), findsOneWidget);
      expect(find.text('Chautarimah Sabai Kura'), findsOneWidget);
      await flushSplashTimer(tester);
    });

    testWidgets('renders logo image and loading animation', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(buildTestApp(isLoggedIn: false));
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      await flushSplashTimer(tester);
    });

    testWidgets('uses branded green background', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(buildTestApp(isLoggedIn: false));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF76C05D));
      await flushSplashTimer(tester);
    });

    testWidgets('contains layout builder and stack structure', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(buildTestApp(isLoggedIn: false));
      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byType(Stack), findsAtLeast(1));
      expect(find.byType(Align), findsNWidgets(2));
      await flushSplashTimer(tester);
    });

    testWidgets('does not throw framework exceptions during startup', (
      tester,
    ) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(buildTestApp(isLoggedIn: false));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      await flushSplashTimer(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
