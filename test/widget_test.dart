
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myapp/main.dart';
import 'package:myapp/providers.dart';


void main() {
  testWidgets('Timer starts and stops', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TimerModel()),
          ChangeNotifierProvider(create: (context) => HistoryModel()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the timer is initially stopped.
    expect(find.text('0m 0s'), findsNothing);

    // Tap the left breast button to start the timer.
    await tester.tap(find.text('L'));
    await tester.pump();

    // Verify that the timer is running.
    expect(find.text('0m 1s'), findsNothing);

    // Tap the left breast button again to stop the timer.
    await tester.tap(find.text('0m 1s'));
    await tester.pump();

    // Verify that the timer is stopped.
    expect(find.text('0m 0s'), findsNothing);
  });
}
