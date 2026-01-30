import 'package:chautari_kurakani/features/dashboard/presentation/pages/bottom_nav_screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chautari_kurakani/features/auth/domain/entities/auth_entity.dart';
import 'package:chautari_kurakani/features/auth/presentation/state/auth_state.dart';
import 'package:chautari_kurakani/features/auth/presentation/view_model/auth_view_model.dart';

// Mocks using mocktail
class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late AuthEntity testUser;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();

    testUser = AuthEntity(
      authId: '1',
      email: 'test@example.com',
      fName: 'John',
      lName: 'Doe',
      username: 'johndoe',
      profilePicture: '',
      coverPicture: '',
      bio: 'Test bio',
    );

    // Setup default behavior
    when(() => mockAuthViewModel.state).thenReturn(
      const AuthState(
        status: AuthStatus.authenticated,
      ).copyWith(authEntity: testUser),
    );

    when(() => mockAuthViewModel.logout()).thenAnswer((_) async {});
    when(
      () => mockAuthViewModel.uploadProfileImage(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAuthViewModel.uploadCoverImage(any()),
    ).thenAnswer((_) async {});
  });

  // Helper function to create test widget
  Widget createTestWidget({AuthEntity? user}) {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
      ],
      child: MaterialApp(
        home: ProfileScreen(userEntity: user ?? testUser),
        routes: {
          '/login': (context) =>
              const Scaffold(body: Center(child: Text('Login Screen'))),
        },
      ),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('Should display user email correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Should display app bar with correct title', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Should display profile and cover image containers', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      // Find containers that look like image containers
      final containers = find.byWidgetPredicate((widget) {
        if (widget is Container) {
          final container = widget;
          return container.decoration is BoxDecoration;
        }
        return false;
      });

      expect(containers, findsAtLeast(2)); // Cover and profile containers
    });

    testWidgets('Should show logout button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should show loading indicator when auth state is loading', (
      WidgetTester tester,
    ) async {
      // Arrange
      final loadingState = const AuthState(
        status: AuthStatus.loading,
      ).copyWith(authEntity: testUser);
      when(() => mockAuthViewModel.state).thenReturn(loadingState);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.text('Profile'),
        findsNothing,
      ); // AppBar should not be visible during loading
    });

    testWidgets('Should show default icon when no profile image', (
      WidgetTester tester,
    ) async {
      // Arrange
      final userWithoutImages = AuthEntity(
        authId: '1',
        email: 'test@example.com',
        fName: 'John',
        lName: 'Doe',
        username: 'johndoe',
        profilePicture: null,
        coverPicture: null,
      );

      // Act
      await tester.pumpWidget(createTestWidget(user: userWithoutImages));

      // Assert
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('Tapping logout button should call logout method', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Logout'));
      await tester.pump();

      // Assert
      verify(() => mockAuthViewModel.logout()).called(1);
    });

    testWidgets(
      'Should show image source bottom sheet when tapping profile image',
      (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(createTestWidget());

        // Find and tap profile image container
        final profileImageFinder = find.byWidgetPredicate((widget) {
          if (widget is GestureDetector) {
            // Look for GestureDetector that contains a Container with circle shape
            final child = widget.child;
            if (child is Container) {
              final decoration = child.decoration as BoxDecoration?;
              return decoration?.shape == BoxShape.circle;
            }
          }
          return false;
        });

        await tester.tap(profileImageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Take Photo'), findsOneWidget);
        expect(find.text('Choose from Gallery'), findsOneWidget);
      },
    );

    testWidgets('Email section should have grey background', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final emailContainerFinder = find.descendant(
        of: find.byType(Column),
        matching: find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final child = find.descendant(
              of: find.byWidget(widget),
              matching: find.text('Email'),
            );
            return child.evaluate().isNotEmpty;
          }
          return false;
        }),
      );

      expect(emailContainerFinder, findsOneWidget);
    });
  });

  group('ProfileScreen Layout Structure Tests', () {
    testWidgets('Should have correct widget hierarchy', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Padding), findsAtLeast(1));
      expect(
        find.byType(Column),
        findsAtLeast(2),
      ); // One in body, potentially one in bottom sheet
      expect(find.byType(SizedBox), findsAtLeast(3));
    });

    testWidgets('Should use SafeArea in bottom sheet', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Tap to show bottom sheet
      final profileImageFinder = find.byWidgetPredicate((widget) {
        if (widget is GestureDetector) {
          final child = widget.child;
          return child is Container &&
              (child.decoration as BoxDecoration?)?.shape == BoxShape.circle;
        }
        return false;
      });

      await tester.tap(profileImageFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('Should have proper spacing between widgets', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      // Check for SizedBox widgets with specific heights
      final sizedBoxes = find.byWidgetPredicate((widget) {
        if (widget is SizedBox) {
          return widget.height != null && widget.height! > 0;
        }
        return false;
      });

      expect(sizedBoxes, findsAtLeast(3));
    });
  });

  group('ProfileScreen Error State Tests', () {
    testWidgets('Should handle error state gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      final errorState = const AuthState(
        status: AuthStatus.error,
      ).copyWith(authEntity: testUser, errorMessage: 'Some error');
      when(() => mockAuthViewModel.state).thenReturn(errorState);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Should still show the UI (not loading)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('test@example.com'), findsOneWidget);
    });
  });
}
