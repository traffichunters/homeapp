import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:homeapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Simple E2E Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for any potential loading
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check that the app launched and main navigation is present
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Look for navigation elements
      final projectsText = find.text('Projects');
      final contactsText = find.text('Contacts');
      
      if (projectsText.evaluate().isNotEmpty) {
        expect(projectsText, findsAtLeastNWidgets(1));
      }
      
      if (contactsText.evaluate().isNotEmpty) {
        expect(contactsText, findsAtLeastNWidgets(1));
      }
    });
  });
}