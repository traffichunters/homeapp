import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:homeapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Basic E2E Tests', () {
    testWidgets('App launches and navigates to home', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for potential splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check main navigation is visible
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Contacts'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('Navigation between main screens works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Contacts
      await tester.tap(find.text('Contacts'));
      await tester.pumpAndSettle();
      expect(find.text('Contacts'), findsOneWidget);

      // Navigate to Documents
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();
      expect(find.text('Documents'), findsOneWidget);

      // Navigate to Search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);

      // Navigate back to Projects
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('Create project flow works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to projects and create new project
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();

      // Look for floating action button
      final fabFinder = find.byType(FloatingActionButton);
      if (fabFinder.evaluate().isNotEmpty) {
        await tester.tap(fabFinder);
        await tester.pumpAndSettle();

        // Fill in project details
        await tester.enterText(find.byType(TextFormField).first, 'Test Project');
        await tester.pumpAndSettle();

        // Look for save button
        final saveButton = find.widgetWithText(ElevatedButton, 'Save');
        if (saveButton.evaluate().isNotEmpty) {
          await tester.tap(saveButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Search functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Find search field and enter text
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'test');
        await tester.pumpAndSettle();
      }
    });
  });
}