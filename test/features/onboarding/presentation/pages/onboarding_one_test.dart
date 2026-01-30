import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_one.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';

void main() {
  testWidgets('OnboardingOne displays all main widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(360, 1000)),
        child: MaterialApp(home: OnboardingOne()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Your Digital,\nChautari Awaits"), findsOneWidget);

    expect(
      find.text(
        "Gather with friends, family and new faces. ChautariKuraKani is the welcoming space for authentic conversations and shared stories.",
      ),
      findsOneWidget,
    );

    expect(find.byType(Image), findsOneWidget);

    expect(find.byType(MyElevatedButton), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
  });
}
