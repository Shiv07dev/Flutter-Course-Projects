import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:route_demo/main.dart';

void main() {
  testWidgets('Sign-in validates both inputs and passes only the username', (
    tester,
  ) async {
    await tester.pumpWidget(const RoutingApp());
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a username'), findsOneWidget);
    expect(find.text('Enter a demo password'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '  Maya  ');
    await tester.enterText(find.byType(TextFormField).at(1), 'fake-password');
    await tester.tap(find.text('Open dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Maya!'), findsOneWidget);
    expect(find.text('fake-password'), findsNothing);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Sign-in'), findsOneWidget);
  });

  testWidgets('Registration checks matching passwords before returning', (
    tester,
  ) async {
    await tester.pumpWidget(const RoutingApp());
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View registration'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Maya');
    await tester.enterText(fields.at(1), 'practice-pass');
    await tester.enterText(fields.at(2), 'mistyped');
    await tester.tap(find.text('Return to sign-in'));
    await tester.pumpAndSettle();
    expect(find.text('Passwords must match'), findsOneWidget);

    await tester.enterText(fields.at(2), 'practice-pass');
    await tester.tap(find.text('Return to sign-in'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Sign-in'), findsOneWidget);
  });
}
