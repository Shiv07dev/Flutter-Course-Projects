import 'package:flutter_test/flutter_test.dart';
import 'package:getx_counter/main.dart' as app;

void main() {
  testWidgets('The counter reacts to add, subtract, and reset', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.text('Subtract'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Subtract'));
    await tester.pumpAndSettle();
    expect(find.text('-1'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  });
}
