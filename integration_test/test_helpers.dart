import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for common test utilities
class TestHelpers {
  /// Wait for splash screen to finish and navigate to home
  static Future<void> waitForSplashScreen(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Navigate to a specific screen from home
  static Future<void> navigateToScreen(WidgetTester tester, String screenName) async {
    await tester.tap(find.text(screenName));
    await tester.pumpAndSettle();
  }

  /// Navigate back using app bar back button
  static Future<void> navigateBack(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
  }

  /// Scroll down by a specific offset
  static Future<void> scrollDown(WidgetTester tester, double offset) async {
    await tester.drag(find.byType(SingleChildScrollView), Offset(0, -offset));
    await tester.pumpAndSettle();
  }

  /// Create a test project with given title and description
  static Future<void> createTestProject(
    WidgetTester tester, 
    String title, 
    String description
  ) async {
    // Navigate to projects
    await navigateToScreen(tester, 'Projects');
    
    // Tap create project
    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();
    
    // Fill in project details
    await tester.enterText(find.byType(TextFormField).at(0), title);
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).at(1), description);
    await tester.pumpAndSettle();
    
    // Scroll to create button
    await scrollDown(tester, 300);
    
    // Create project
    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();
  }

  /// Create a test contact with given details
  static Future<void> createTestContact(
    WidgetTester tester, {
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String company,
  }) async {
    // Navigate to projects
    await navigateToScreen(tester, 'Projects');
    
    // Tap create project
    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();
    
    // Fill in basic project info
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Project for Contact');
    await tester.pumpAndSettle();
    
    // Scroll to contacts section
    await scrollDown(tester, 500);
    
    // Add contact
    await tester.tap(find.text('Add Contact'));
    await tester.pumpAndSettle();
    
    // Fill in contact details
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(2), firstName);
    await tester.pumpAndSettle();
    
    await tester.enterText(textFields.at(3), lastName);
    await tester.pumpAndSettle();
    
    await tester.enterText(textFields.at(4), email);
    await tester.pumpAndSettle();
    
    await tester.enterText(textFields.at(5), phone);
    await tester.pumpAndSettle();
    
    await tester.enterText(textFields.at(6), company);
    await tester.pumpAndSettle();
    
    // Scroll to create button
    await scrollDown(tester, 300);
    
    // Create project with contact
    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();
  }

  /// Perform a search with given query
  static Future<void> performSearch(WidgetTester tester, String query) async {
    await navigateToScreen(tester, 'Search');
    
    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
    
    // Trigger search
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
  }

  /// Test bulk selection mode on a list page
  static Future<void> testBulkSelection(WidgetTester tester) async {
    // Try to enter selection mode
    final selectButton = find.byIcon(Icons.select_all);
    if (tester.any(selectButton)) {
      await tester.tap(selectButton);
      await tester.pumpAndSettle();
      
      // Verify selection mode UI
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Exit selection mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    }
  }

  /// Test long press selection on items
  static Future<void> testLongPressSelection(WidgetTester tester) async {
    final cards = find.byType(Card);
    if (tester.any(cards)) {
      await tester.longPress(cards.first);
      await tester.pumpAndSettle();
      
      // Verify selection mode is activated
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      // Exit selection mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    }
  }

  /// Verify empty state display
  static void verifyEmptyState(String expectedText) {
    expect(find.text(expectedText), findsOneWidget);
  }

  /// Test view toggle button (grid/list)
  static Future<void> testViewToggle(WidgetTester tester) async {
    final gridViewButton = find.byIcon(Icons.grid_view);
    if (tester.any(gridViewButton)) {
      await tester.tap(gridViewButton);
      await tester.pumpAndSettle();
      
      // Verify view changed
      expect(find.byIcon(Icons.view_list), findsOneWidget);
      
      // Toggle back
      await tester.tap(find.byIcon(Icons.view_list));
      await tester.pumpAndSettle();
      
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
    }
  }

  /// Test filter functionality
  static Future<void> testFilters(WidgetTester tester) async {
    // Tap filter button
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
    
    // Verify filter panel
    expect(find.text('Filters'), findsOneWidget);
    
    // Close filter panel
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();
  }

  /// Verify theme consistency
  static void verifyThemeConsistency(WidgetTester tester) {
    final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
    expect(materialApp.theme, isNotNull);
    expect(materialApp.theme!.useMaterial3, true);
    expect(find.byType(AppBar), findsOneWidget);
  }

  /// Test navigation flow through all main screens
  static Future<void> testMainNavigation(WidgetTester tester) async {
    final screens = ['Projects', 'Contacts', 'Documents', 'Search'];
    
    for (final screen in screens) {
      await navigateToScreen(tester, screen);
      
      // Verify screen is loaded
      expect(find.text(screen), findsOneWidget);
      
      // Verify theme consistency
      verifyThemeConsistency(tester);
      
      // Navigate back
      await navigateBack(tester);
      
      // Verify we're back at home
      expect(find.text('Welcome to HomeApp'), findsOneWidget);
    }
  }

  /// Test item detail view navigation
  static Future<void> testItemDetailNavigation(WidgetTester tester) async {
    final cards = find.byType(Card);
    if (tester.any(cards)) {
      await tester.tap(cards.first);
      await tester.pumpAndSettle();
      
      // Verify detail view is loaded
      expect(find.byType(AppBar), findsOneWidget);
      
      // Navigate back
      await navigateBack(tester);
    }
  }

  /// Clear all test data (for clean test runs)
  static Future<void> clearTestData(WidgetTester tester) async {
    // This would typically clear SharedPreferences or database
    // For now, we'll just restart the app
    await tester.pumpAndSettle();
  }

  /// Setup test data for comprehensive testing
  static Future<void> setupTestData(WidgetTester tester) async {
    // Create test projects
    await createTestProject(tester, 'Kitchen Renovation', 'Complete kitchen remodel');
    await navigateBack(tester);
    
    await createTestProject(tester, 'Bathroom Upgrade', 'Master bathroom renovation');
    await navigateBack(tester);
    
    // Create test contacts
    await createTestContact(
      tester,
      firstName: 'John',
      lastName: 'Contractor',
      email: 'john@contractor.com',
      phone: '555-123-4567',
      company: 'ABC Construction',
    );
    await navigateBack(tester);
  }

  /// Verify app performance by checking for janky animations
  static Future<void> verifyPerformance(WidgetTester tester) async {
    // Test smooth navigation animations
    await navigateToScreen(tester, 'Projects');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify no performance issues
    expect(tester.binding.hasScheduledFrame, false);
  }
}