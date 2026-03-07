import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_new_password.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_pin_screen.dart';
import 'package:chautari_kurakani/features/auth/presentation/pages/forget_password/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

Widget wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: child));
}

void main() {
  Future<void> setLargeScreen(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1200, 2600);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Forgot Password Flow Widget Tests', () {
    testWidgets('forget screen renders recovery title', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(wrap(const ForgetPasswordScreen()));
      expect(find.text('Recover your password'), findsOneWidget);
    });

    testWidgets('forget screen renders email input', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(wrap(const ForgetPasswordScreen()));
      expect(find.text('Enter your email'), findsWidgets);
    });

    testWidgets('forget screen renders next and login actions', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(wrap(const ForgetPasswordScreen()));
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('forget screen shows otp instruction', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(wrap(const ForgetPasswordScreen()));
      expect(find.textContaining('6-digit code'), findsOneWidget);
    });

    testWidgets('pin screen renders entered email in instruction', (
      tester,
    ) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(
        wrap(const ForgetPasswordPinScreen(email: 'test@example.com')),
      );
      expect(find.textContaining('test@example.com'), findsOneWidget);
    });

    testWidgets('pin screen shows resend and next buttons', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(
        wrap(const ForgetPasswordPinScreen(email: 'test@example.com')),
      );
      expect(find.text('Resend'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('pin screen contains 6-digit pin widget', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(
        wrap(const ForgetPasswordPinScreen(email: 'test@example.com')),
      );
      expect(find.byType(PinCodeTextField), findsOneWidget);
    });

    testWidgets('new password screen shows password fields', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(
        wrap(
          const ForgetPasswordNewPassword(
            email: 'test@example.com',
            code: '123456',
          ),
        ),
      );
      expect(find.text('New Password'), findsWidgets);
      expect(find.text('Confirm Password'), findsWidgets);
    });

    testWidgets('new password screen shows confirm action', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(
        wrap(
          const ForgetPasswordNewPassword(
            email: 'test@example.com',
            code: '123456',
          ),
        ),
      );
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('new password token mode has no missing-data warning', (
      tester,
    ) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(
        wrap(const ForgetPasswordNewPassword(token: 'abc')),
      );
      expect(find.textContaining('Missing reset data'), findsNothing);
    });

    testWidgets('new password shows warning when reset data missing', (
      tester,
    ) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(wrap(const ForgetPasswordNewPassword()));
      expect(find.textContaining('Missing reset data'), findsOneWidget);
    });

    testWidgets('new password screen contains back button', (tester) async {
      await setLargeScreen(tester);
      await tester.pumpWidget(
        wrap(
          const ForgetPasswordNewPassword(
            email: 'test@example.com',
            code: '123456',
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
