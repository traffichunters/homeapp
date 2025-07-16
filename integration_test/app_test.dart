import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:homeapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HomeApp E2E Tests', () {
    
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen is displayed
      expect(find.text('HomeApp'), findsOneWidget);
      expect(find.text('Smart Home Management'), findsOneWidget);
      
      // Wait for navigation to home screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify home screen is displayed
      expect(find.text('Welcome to HomeApp'), findsOneWidget);
    });

    testWidgets('Navigation flow between main screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test navigation to Projects
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      expect(find.text('House Projects'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to HomeApp'), findsOneWidget);

      // Test navigation to Contacts
      await tester.tap(find.text('Contacts'));
      await tester.pumpAndSettle();
      expect(find.text('Contacts'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test navigation to Documents
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();
      expect(find.text('Documents'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test navigation to Search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('Project creation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Projects
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();

      // Tap on Create Project
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      // Verify Create Project page is displayed
      expect(find.text('Create Project'), findsOneWidget);

      // Fill in project title
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Kitchen Renovation');
      await tester.pumpAndSettle();

      // Fill in project description
      await tester.enterText(find.byType(TextFormField).at(1), 'Complete kitchen renovation including cabinets, countertops, and appliances');
      await tester.pumpAndSettle();

      // Scroll down to ensure Create Project button is visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Tap Create Project button
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      // Verify project was created and we're back to projects list
      expect(find.text('House Projects'), findsOneWidget);
      expect(find.text('Test Kitchen Renovation'), findsOneWidget);
    });

    testWidgets('Contact creation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Projects
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();

      // Tap on Create Project
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      // Fill in basic project info
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Bathroom Project');
      await tester.pumpAndSettle();

      // Navigate to Add Contact section
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Tap Add Contact button
      await tester.tap(find.text('Add Contact'));
      await tester.pumpAndSettle();

      // Fill in contact details
      await tester.enterText(find.byType(TextFormField).at(2), 'John');
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(3), 'Contractor');
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(4), 'john@contractor.com');
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(5), '555-123-4567');
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).at(6), 'ABC Construction');
      await tester.pumpAndSettle();

      // Scroll down to see the Create Project button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Create the project
      await tester.tap(find.text('Create Project'));
      await tester.pumpAndSettle();

      // Verify project was created
      expect(find.text('House Projects'), findsOneWidget);
      expect(find.text('Test Bathroom Project'), findsOneWidget);
    });

    testWidgets('Search functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Verify search page is displayed
      expect(find.text('Search'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'kitchen');
      await tester.pumpAndSettle();

      // Verify search results are displayed (if any projects exist)
      // This will depend on whether previous tests have created projects
      await tester.pump(const Duration(seconds: 1));
      
      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Verify search is cleared
      expect(find.text('kitchen'), findsNothing);
    });

    testWidgets('Search filters functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Tap filter button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Verify filter panel is displayed
      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('File Types'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Date Range'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);

      // Test date range picker
      await tester.tap(find.text('Select date range'));
      await tester.pumpAndSettle();

      // Close date picker by tapping outside (if it opened)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Close filter panel
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();
    });

    testWidgets('Documents list view toggle', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Documents
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // Verify documents page is displayed
      expect(find.text('Documents'), findsOneWidget);

      // Test view toggle button
      final viewToggleButton = find.byIcon(Icons.grid_view);
      if (tester.any(viewToggleButton)) {
        await tester.tap(viewToggleButton);
        await tester.pumpAndSettle();
        
        // Verify view changed to grid view
        expect(find.byIcon(Icons.view_list), findsOneWidget);
        
        // Toggle back to list view
        await tester.tap(find.byIcon(Icons.view_list));
        await tester.pumpAndSettle();
        
        // Verify view changed back to list view
        expect(find.byIcon(Icons.grid_view), findsOneWidget);
      }
    });

    testWidgets('Contacts list bulk operations', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Contacts
      await tester.tap(find.text('Contacts'));
      await tester.pumpAndSettle();

      // Verify contacts page is displayed
      expect(find.text('Contacts'), findsOneWidget);

      // Test selection mode button
      final selectButton = find.byIcon(Icons.select_all);
      if (tester.any(selectButton)) {
        await tester.tap(selectButton);
        await tester.pumpAndSettle();
        
        // Verify selection mode is activated
        expect(find.byIcon(Icons.close), findsOneWidget);
        
        // Exit selection mode
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Document preview functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Documents
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // If there are documents, test opening one
      final documentCards = find.byType(Card);
      if (tester.any(documentCards)) {
        await tester.tap(documentCards.first);
        await tester.pumpAndSettle();
        
        // Verify document details page is displayed
        expect(find.text('Document Preview'), findsOneWidget);
        expect(find.text('Document Information'), findsOneWidget);
        expect(find.text('Actions'), findsOneWidget);
        
        // Test back navigation
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        
        // Verify we're back to documents list
        expect(find.text('Documents'), findsOneWidget);
      }
    });

    testWidgets('Search history functionality', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Search
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Perform a search to add to history
      await tester.enterText(find.byType(TextField), 'renovation');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Clear search field
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Tap search field to show suggestions
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Test history button if it exists
      final historyButton = find.byIcon(Icons.history);
      if (tester.any(historyButton)) {
        await tester.tap(historyButton);
        await tester.pumpAndSettle();
        
        // Verify search history is shown
        expect(find.text('Recent searches'), findsOneWidget);
      }
    });

    testWidgets('Project detail view and navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Projects
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();

      // If there are projects, test opening one
      final projectCards = find.byType(Card);
      if (tester.any(projectCards)) {
        await tester.tap(projectCards.first);
        await tester.pumpAndSettle();
        
        // Verify project details page is displayed
        expect(find.text('Project Overview'), findsOneWidget);
        expect(find.text('Contacts'), findsOneWidget);
        expect(find.text('Activities'), findsOneWidget);
        expect(find.text('Documents'), findsOneWidget);
        
        // Test back navigation
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        
        // Verify we're back to projects list
        expect(find.text('House Projects'), findsOneWidget);
      }
    });

    testWidgets('Contact detail view and star ratings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Contacts
      await tester.tap(find.text('Contacts'));
      await tester.pumpAndSettle();

      // If there are contacts, test opening one
      final contactCards = find.byType(Card);
      if (tester.any(contactCards)) {
        await tester.tap(contactCards.first);
        await tester.pumpAndSettle();
        
        // Verify contact details page is displayed
        expect(find.text('Contact Information'), findsOneWidget);
        expect(find.text('Associated Projects'), findsOneWidget);
        
        // Look for star rating display
        expect(find.byIcon(Icons.star), findsWidgets);
        
        // Test back navigation
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        
        // Verify we're back to contacts list
        expect(find.text('Contacts'), findsOneWidget);
      }
    });

    testWidgets('Long press for bulk selection', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Documents
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();

      // If there are documents, test long press selection
      final documentCards = find.byType(Card);
      if (tester.any(documentCards)) {
        await tester.longPress(documentCards.first);
        await tester.pumpAndSettle();
        
        // Verify selection mode is activated
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
        
        // Exit selection mode
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('App theme and UI consistency', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify Material Design 3 theme is applied
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.theme!.useMaterial3, true);

      // Test navigation through different screens to verify consistent theming
      final screens = ['Projects', 'Contacts', 'Documents', 'Search'];
      
      for (final screen in screens) {
        await tester.tap(find.text(screen));
        await tester.pumpAndSettle();
        
        // Verify app bar is displayed with correct theme
        expect(find.byType(AppBar), findsOneWidget);
        
        // Navigate back to home
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Error handling and edge cases', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test empty state displays
      await tester.tap(find.text('Projects'));
      await tester.pumpAndSettle();
      
      // If no projects exist, verify empty state
      final emptyStateIcon = find.byIcon(Icons.home_work_outlined);
      if (tester.any(emptyStateIcon)) {
        expect(find.text('No projects yet'), findsOneWidget);
      }

      // Test contacts empty state
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Contacts'));
      await tester.pumpAndSettle();
      
      final contactsEmptyIcon = find.byIcon(Icons.people_outline);
      if (tester.any(contactsEmptyIcon)) {
        expect(find.text('No contacts found'), findsOneWidget);
      }

      // Test documents empty state
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();
      
      final documentsEmptyIcon = find.byIcon(Icons.folder_open);
      if (tester.any(documentsEmptyIcon)) {
        expect(find.text('No documents found'), findsOneWidget);
      }
    });
  });
}