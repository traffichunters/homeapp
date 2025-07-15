// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homeapp/main.dart';

void main() {
  testWidgets('HomeApp loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HomeApp());

    // Verify that splash screen loads with HomeApp text.
    expect(find.text('HomeApp'), findsOneWidget);
    expect(find.text('Welcome to your smart home'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    
    // Wait for splash screen timer to complete and navigate to home screen
    await tester.pumpAndSettle(const Duration(seconds: 4));
    
    // Verify that we navigated to the home screen
    expect(find.text('Your Smart Home Control Center'), findsOneWidget);
  });
}
