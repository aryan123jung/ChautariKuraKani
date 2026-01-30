import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chautari_kurakani/features/onboarding/presentation/pages/onboarding_two.dart';
import 'package:chautari_kurakani/core/widgets/my_elevated_button.dart';

void main() {
  testWidgets('OnboardingTwo displays all main widgets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(360, 1000)),
        child: MaterialApp(home: OnboardingTwo()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Speak Freely,\nListen Deeply"), findsOneWidget);

    expect(
      find.text(
        "Post thoughts, ask questions and engage in meaningful KuraKani. Find perspective you wont find it anywhere else.",
      ),
      findsOneWidget,
    );

    expect(find.byType(Image), findsOneWidget);

    expect(find.byType(MyElevatedButton), findsOneWidget);
    expect(find.text("Next"), findsOneWidget);
  });
}
