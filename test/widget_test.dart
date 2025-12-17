
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
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => TimerModel()),
          ChangeNotifierProvider(create: (context) => HistoryModel()),
        ],
        child: const MyApp(),
      ),
    );

    // Let the app settle.
    await tester.pumpAndSettle();

    // Verify that the timer is initially stopped and the button shows 'L'.
    expect(find.text('L'), findsOneWidget);

    // Tap the left breast button to start the timer.
    await tester.tap(find.text('L'));
    await tester.pump();

    // Wait for 1 second.
    await tester.pump(const Duration(seconds: 1));

    // Verify that the timer is running and shows the elapsed time.
    expect(find.text('1s'), findsOneWidget);

    // Tap the button again to stop the timer.
    await tester.tap(find.text('1s'));
    await tester.pump();

    // Verify that the timer is stopped and the button shows 'L' again.
    expect(find.text('L'), findsOneWidget);
    expect(find.text('1s'), findsNothing);
  });
}
