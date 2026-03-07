import 'package:chautari_kurakani/features/profile/presentation/widgets/edit_profile_widget.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/friend_card_widget.dart';
import 'package:chautari_kurakani/features/profile/presentation/widgets/side_nav_widget.dart';
import 'package:chautari_kurakani/features/search/domain/entities/search_user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('SideNavigationDrawer Widget Tests', () {
    testWidgets('renders user header info', (tester) async {
      await tester.pumpWidget(
        wrap(
          SideNavigationDrawer(
            fullName: 'John Doe',
            email: 'john@example.com',
            onLogout: () {},
            onEditProfile: () {},
            onSettings: () {},
            onHelp: () {},
            onPrivacyPolicy: () {},
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('shows all primary actions', (tester) async {
      await tester.pumpWidget(
        wrap(
          SideNavigationDrawer(
            fullName: 'John Doe',
            email: 'john@example.com',
            onLogout: () {},
            onEditProfile: () {},
            onSettings: () {},
            onHelp: () {},
            onPrivacyPolicy: () {},
          ),
        ),
      );

      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Logout', skipOffstage: false), findsWidgets);
    });

    testWidgets('shows version label', (tester) async {
      await tester.pumpWidget(
        wrap(
          SideNavigationDrawer(
            fullName: 'John Doe',
            email: 'john@example.com',
            onLogout: () {},
            onEditProfile: () {},
            onSettings: () {},
            onHelp: () {},
            onPrivacyPolicy: () {},
          ),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('Version 1.0.0', skipOffstage: false), findsOneWidget);
    });
  });

  group('EditProfileWidget Widget Tests', () {
    testWidgets('renders editable fields', (tester) async {
      await tester.pumpWidget(
        wrap(
          EditProfileWidget(
            firstName: 'John',
            lastName: 'Doe',
            username: 'john_doe',
            onSave: (_, __, ___) async => true,
          ),
        ),
      );

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Last name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('shows cancel and save actions', (tester) async {
      await tester.pumpWidget(
        wrap(
          EditProfileWidget(
            firstName: 'John',
            lastName: 'Doe',
            username: 'john_doe',
            onSave: (_, __, ___) async => true,
          ),
        ),
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets('shows validation snackbar on empty save', (tester) async {
      await tester.pumpWidget(
        wrap(
          EditProfileWidget(
            firstName: '',
            lastName: '',
            username: '',
            onSave: (_, __, ___) async => false,
          ),
        ),
      );

      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      expect(find.text('All fields are required'), findsOneWidget);
    });

    testWidgets('calls onSave and closes when save succeeds', (tester) async {
      int called = 0;
      await tester.pumpWidget(
        wrap(
          EditProfileWidget(
            firstName: 'John',
            lastName: 'Doe',
            username: 'john_doe',
            onSave: (_, __, ___) async {
              called++;
              return true;
            },
          ),
        ),
      );

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(called, 1);
    });
  });

  group('FriendCard Widget Tests', () {
    final friend = SearchUserEntity(
      id: 'u1',
      firstName: 'Jane',
      lastName: 'Doe',
      email: 'jane@example.com',
      username: 'jane_doe',
      profileUrl: null,
      coverUrl: null,
    );

    testWidgets('renders friend identity', (tester) async {
      await tester.pumpWidget(wrap(FriendCard(friend: friend, onView: () {})));
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('@jane_doe'), findsOneWidget);
    });

    testWidgets('renders view action', (tester) async {
      await tester.pumpWidget(wrap(FriendCard(friend: friend, onView: () {})));
      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('renders message action when callback provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(FriendCard(friend: friend, onView: () {}, onMessage: () {})),
      );
      expect(find.byTooltip('Message'), findsOneWidget);
    });
  });
}
