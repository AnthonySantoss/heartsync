import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heartsync/main.dart';

import 'package:heartsync/src/features/Menu/presentation/view/Home_page_screen.dart'; // Corrigido o caminho

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async { // Corrigido "as" para "async"
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomePageScreen());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add)); // Corrigido "icons" para "Icons"
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}