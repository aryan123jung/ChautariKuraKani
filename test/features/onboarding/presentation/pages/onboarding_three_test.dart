import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_three.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';

void main() {
  testWidgets('OnboardingThree displays all main widgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(360, 1000)), 
        child: MaterialApp(home: OnboardingThree()),
      ),
    );

    await tester.pumpAndSettle(); 

    expect(find.text("Connect \nAcross Borders"), findsOneWidget);

    expect(
      find.text(
        "Whether near or far, join conversations relevant to your interest, region or culture. The world is waiting to chat"
      ),
      findsOneWidget,
    );

    expect(find.byType(Image), findsOneWidget);

    expect(find.byType(MyElevatedButton), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
  });
}
