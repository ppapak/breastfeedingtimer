
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:myapp/main.dart';
import 'package:myapp/providers.dart';
import 'package:myapp/baby_provider.dart';


void main() {
  testWidgets('Timer starts and stops', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TimerModel()),
          ChangeNotifierProvider(create: (context) => HistoryModel()),
          ChangeNotifierProvider(create: (context) => BabyModel()),
        ],
        child: const BreastfeedingApp(),
      ),
    );

    // Verify that the timer is initially stopped.
    expect(find.text('00m 00s'), findsOneWidget);

    // Tap the left breast button to start the timer.
    await tester.tap(find.byKey(const Key('left_breast_button')));
    await tester.pumpAndSettle();

    // Wait for 1 second.
    await Future.delayed(const Duration(seconds: 1));

    // pump the widget tree to reflect the new state
    await tester.pump();

    // Verify that the timer is running.
    expect(find.text('00m 01s'), findsOneWidget);

    // Tap the left breast button again to stop the timer.
    await tester.tap(find.byKey(const Key('left_breast_button')));
    await tester.pumpAndSettle();

    // Verify that the timer is stopped.
    expect(find.text('00m 00s'), findsOneWidget);
  });
}
