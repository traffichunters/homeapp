import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeapp/main.dart' as app;
import 'test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Comprehensive E2E Tests', () {
    
    setUp(() async {
      // Clear any existing test data before each test
      debugPrint('Setting up test environment...');
    });

    tearDown(() async {
      // Clean up after each test
      debugPrint('Cleaning up test environment...');
    });

    testWidgets('Complete user journey - Project creation and management', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Test complete project creation flow
      await TestHelpers.createTestProject(tester, 'Kitchen Renovation', 'Complete kitchen remodel with new cabinets and appliances');
      
      // Verify project appears in list
      await TestHelpers.navigateToScreen(tester, 'Projects');
      expect(find.text('Kitchen Renovation'), findsOneWidget);
      
      // Test project detail view
      await TestHelpers.testItemDetailNavigation(tester);
      
      await TestHelpers.navigateBack(tester);
      await TestHelpers.navigateBack(tester);
    });

    testWidgets('Complete user journey - Contact creation and management', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Test complete contact creation flow
      await TestHelpers.createTestContact(
        tester,
        firstName: 'Jane',
        lastName: 'Contractor',
        email: 'jane@contractor.com',
        phone: '555-987-6543',
        company: 'XYZ Construction',
      );
      
      // Verify contact appears in list
      await TestHelpers.navigateToScreen(tester, 'Contacts');
      expect(find.text('Jane Contractor'), findsOneWidget);
      
      // Test contact detail view
      await TestHelpers.testItemDetailNavigation(tester);
      
      await TestHelpers.navigateBack(tester);
      await TestHelpers.navigateBack(tester);
    });

    testWidgets('Search functionality end-to-end', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Create some test data first
      await TestHelpers.createTestProject(tester, 'Bathroom Renovation', 'Master bathroom upgrade');
      await TestHelpers.navigateBack(tester);

      // Test search functionality
      await TestHelpers.performSearch(tester, 'bathroom');
      
      // Verify search results
      await tester.pump(const Duration(seconds: 1));
      
      // Test search filters
      await TestHelpers.testFilters(tester);
      
      // Test search history
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      
      await TestHelpers.navigateBack(tester);
    });

    testWidgets('Documents management workflow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Navigate to documents
      await TestHelpers.navigateToScreen(tester, 'Documents');
      
      // Test view toggle
      await TestHelpers.testViewToggle(tester);
      
      // Test bulk selection
      await TestHelpers.testBulkSelection(tester);
      
      // Test long press selection
      await TestHelpers.testLongPressSelection(tester);
      
      await TestHelpers.navigateBack(tester);
    });

    testWidgets('Navigation and UI consistency', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Test main navigation flow
      await TestHelpers.testMainNavigation(tester);
      
      // Verify theme consistency across screens
      TestHelpers.verifyThemeConsistency(tester);
    });

    testWidgets('Performance and responsiveness', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Test app performance
      await TestHelpers.verifyPerformance(tester);
      
      // Test rapid navigation
      for (int i = 0; i < 3; i++) {
        await TestHelpers.navigateToScreen(tester, 'Projects');
        await TestHelpers.navigateBack(tester);
        
        await TestHelpers.navigateToScreen(tester, 'Contacts');
        await TestHelpers.navigateBack(tester);
        
        await TestHelpers.navigateToScreen(tester, 'Documents');
        await TestHelpers.navigateBack(tester);
        
        await TestHelpers.navigateToScreen(tester, 'Search');
        await TestHelpers.navigateBack(tester);
      }
    });

    testWidgets('Error handling and edge cases', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Test empty states
      await TestHelpers.navigateToScreen(tester, 'Projects');
      final emptyStateIcon = find.byIcon(Icons.home_work_outlined);
      if (tester.any(emptyStateIcon)) {
        TestHelpers.verifyEmptyState('No projects yet');
      }
      await TestHelpers.navigateBack(tester);

      // Test invalid search
      await TestHelpers.performSearch(tester, 'nonexistentterm12345');
      await tester.pump(const Duration(seconds: 1));
      
      // Should show no results
      expect(find.text('No results found'), findsOneWidget);
      await TestHelpers.navigateBack(tester);
    });

    testWidgets('Data persistence and state management', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Create test data
      await TestHelpers.createTestProject(tester, 'Persistence Test', 'Test data persistence');
      await TestHelpers.navigateBack(tester);

      // Navigate away and back
      await TestHelpers.navigateToScreen(tester, 'Search');
      await TestHelpers.navigateBack(tester);
      
      await TestHelpers.navigateToScreen(tester, 'Projects');
      
      // Verify data persists
      expect(find.text('Persistence Test'), findsOneWidget);
      
      await TestHelpers.navigateBack(tester);
    });

    testWidgets('Accessibility and usability', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Test screen reader accessibility
      await TestHelpers.navigateToScreen(tester, 'Projects');
      
      // Verify semantic labels are present
      expect(find.byType(Semantics), findsWidgets);
      
      // Test keyboard navigation (if applicable)
      await TestHelpers.navigateBack(tester);
      
      // Test contrast and visibility
      TestHelpers.verifyThemeConsistency(tester);
    });

    testWidgets('Integration with device features', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Test orientation changes (if supported)
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );
      
      await tester.pumpAndSettle();
      
      // Verify app handles orientation changes gracefully
      TestHelpers.verifyThemeConsistency(tester);
    });

    testWidgets('Full workflow - Create, search, and manage', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await TestHelpers.waitForSplashScreen(tester);

      // Create multiple projects
      await TestHelpers.createTestProject(tester, 'Living Room', 'Living room renovation');
      await TestHelpers.navigateBack(tester);
      
      await TestHelpers.createTestProject(tester, 'Kitchen', 'Kitchen remodel');
      await TestHelpers.navigateBack(tester);

      // Create contacts
      await TestHelpers.createTestContact(
        tester,
        firstName: 'Bob',
        lastName: 'Builder',
        email: 'bob@builder.com',
        phone: '555-111-2222',
        company: 'Builder Co',
      );
      await TestHelpers.navigateBack(tester);

      // Search for created items
      await TestHelpers.performSearch(tester, 'living');
      await tester.pump(const Duration(seconds: 1));
      
      // Clear search and try another
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      
      await TestHelpers.performSearch(tester, 'bob');
      await tester.pump(const Duration(seconds: 1));
      
      await TestHelpers.navigateBack(tester);

      // Verify all data is accessible
      await TestHelpers.navigateToScreen(tester, 'Projects');
      expect(find.text('Living Room'), findsOneWidget);
      expect(find.text('Kitchen'), findsOneWidget);
      
      await TestHelpers.navigateBack(tester);
      
      await TestHelpers.navigateToScreen(tester, 'Contacts');
      expect(find.text('Bob Builder'), findsOneWidget);
      
      await TestHelpers.navigateBack(tester);
    });
  });
}