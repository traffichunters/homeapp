import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homeapp/services/storage_service.dart';
import 'package:homeapp/models/project.dart';
import 'package:homeapp/models/contact.dart';
import 'package:homeapp/models/activity.dart';
import 'package:homeapp/models/document.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;
    late DateTime testDate;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      testDate = DateTime(2024, 1, 15, 10, 30);
    });

    group('Project CRUD Operations', () {
      test('should insert and retrieve a project', () async {
        final project = Project(
          title: 'Kitchen Renovation',
          description: 'Complete kitchen remodel',
          createdDate: testDate,
          updatedDate: testDate,
          tags: 'renovation,kitchen',
        );

        final projectId = await storageService.insertProject(project);
        expect(projectId, equals(1));

        final retrievedProject = await storageService.getProject(projectId);
        expect(retrievedProject, isNotNull);
        expect(retrievedProject!.id, equals(projectId));
        expect(retrievedProject.title, equals('Kitchen Renovation'));
        expect(retrievedProject.description, equals('Complete kitchen remodel'));
        expect(retrievedProject.tags, equals('renovation,kitchen'));
      });

      test('should assign incremental IDs to projects', () async {
        final project1 = Project(
          title: 'Project 1',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final project2 = Project(
          title: 'Project 2',
          createdDate: testDate,
          updatedDate: testDate,
        );

        final id1 = await storageService.insertProject(project1);
        final id2 = await storageService.insertProject(project2);

        expect(id1, equals(1));
        expect(id2, equals(2));
      });

      test('should get all projects', () async {
        final project1 = Project(
          title: 'Project 1',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final project2 = Project(
          title: 'Project 2',
          createdDate: testDate,
          updatedDate: testDate,
        );

        await storageService.insertProject(project1);
        await storageService.insertProject(project2);

        final projects = await storageService.getAllProjects();
        expect(projects.length, equals(2));
        expect(projects[0].title, equals('Project 1'));
        expect(projects[1].title, equals('Project 2'));
      });

      test('should return empty list when no projects exist', () async {
        final projects = await storageService.getAllProjects();
        expect(projects, isEmpty);
      });

      test('should return null for non-existent project', () async {
        final project = await storageService.getProject(999);
        expect(project, isNull);
      });

      test('should handle project with minimal data', () async {
        final project = Project(
          title: 'Minimal Project',
          createdDate: testDate,
          updatedDate: testDate,
        );

        final projectId = await storageService.insertProject(project);
        final retrievedProject = await storageService.getProject(projectId);

        expect(retrievedProject, isNotNull);
        expect(retrievedProject!.title, equals('Minimal Project'));
        expect(retrievedProject.description, isNull);
        expect(retrievedProject.tags, isNull);
      });
    });

    group('Contact CRUD Operations', () {
      test('should insert and retrieve a contact', () async {
        final contact = Contact(
          firstName: 'John',
          lastName: 'Doe',
          companyName: 'ABC Construction',
          email: 'john@abc.com',
          phoneNumber: '555-0123',
          url: 'https://abc.com',
          createdDate: testDate,
        );

        final contactId = await storageService.insertContact(contact);
        expect(contactId, equals(1));

        final retrievedContact = await storageService.getContact(contactId);
        expect(retrievedContact, isNotNull);
        expect(retrievedContact!.id, equals(contactId));
        expect(retrievedContact.firstName, equals('John'));
        expect(retrievedContact.lastName, equals('Doe'));
        expect(retrievedContact.fullName, equals('John Doe'));
        expect(retrievedContact.companyName, equals('ABC Construction'));
        expect(retrievedContact.email, equals('john@abc.com'));
      });

      test('should assign incremental IDs to contacts', () async {
        final contact1 = Contact(
          firstName: 'John',
          lastName: 'Doe',
          createdDate: testDate,
        );
        final contact2 = Contact(
          firstName: 'Jane',
          lastName: 'Smith',
          createdDate: testDate,
        );

        final id1 = await storageService.insertContact(contact1);
        final id2 = await storageService.insertContact(contact2);

        expect(id1, equals(1));
        expect(id2, equals(2));
      });

      test('should get all contacts', () async {
        final contact1 = Contact(
          firstName: 'John',
          lastName: 'Doe',
          createdDate: testDate,
        );
        final contact2 = Contact(
          firstName: 'Jane',
          lastName: 'Smith',
          createdDate: testDate,
        );

        await storageService.insertContact(contact1);
        await storageService.insertContact(contact2);

        final contacts = await storageService.getAllContacts();
        expect(contacts.length, equals(2));
        expect(contacts[0].fullName, equals('John Doe'));
        expect(contacts[1].fullName, equals('Jane Smith'));
      });

      test('should return empty list when no contacts exist', () async {
        final contacts = await storageService.getAllContacts();
        expect(contacts, isEmpty);
      });

      test('should return null for non-existent contact', () async {
        final contact = await storageService.getContact(999);
        expect(contact, isNull);
      });

      test('should handle contact with minimal data', () async {
        final contact = Contact(
          firstName: 'John',
          lastName: 'Doe',
          createdDate: testDate,
        );

        final contactId = await storageService.insertContact(contact);
        final retrievedContact = await storageService.getContact(contactId);

        expect(retrievedContact, isNotNull);
        expect(retrievedContact!.firstName, equals('John'));
        expect(retrievedContact.lastName, equals('Doe'));
        expect(retrievedContact.companyName, isNull);
        expect(retrievedContact.email, isNull);
        expect(retrievedContact.phoneNumber, isNull);
        expect(retrievedContact.url, isNull);
      });
    });

    group('Project-Contact Linking', () {
      test('should link project and contact', () async {
        final project = Project(
          title: 'Test Project',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final contact = Contact(
          firstName: 'John',
          lastName: 'Doe',
          createdDate: testDate,
        );

        final projectId = await storageService.insertProject(project);
        final contactId = await storageService.insertContact(contact);

        await storageService.linkProjectContact(projectId, contactId);

        final projectContacts = await storageService.getContactsForProject(projectId);
        expect(projectContacts.length, equals(1));
        expect(projectContacts[0].id, equals(contactId));
        expect(projectContacts[0].fullName, equals('John Doe'));
      });

      test('should handle multiple contacts for one project', () async {
        final project = Project(
          title: 'Test Project',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final contact1 = Contact(
          firstName: 'John',
          lastName: 'Doe',
          createdDate: testDate,
        );
        final contact2 = Contact(
          firstName: 'Jane',
          lastName: 'Smith',
          createdDate: testDate,
        );

        final projectId = await storageService.insertProject(project);
        final contactId1 = await storageService.insertContact(contact1);
        final contactId2 = await storageService.insertContact(contact2);

        await storageService.linkProjectContact(projectId, contactId1);
        await storageService.linkProjectContact(projectId, contactId2);

        final projectContacts = await storageService.getContactsForProject(projectId);
        expect(projectContacts.length, equals(2));
        expect(projectContacts.map((c) => c.fullName).toList(), containsAll(['John Doe', 'Jane Smith']));
      });

      test('should not create duplicate links', () async {
        final project = Project(
          title: 'Test Project',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final contact = Contact(
          firstName: 'John',
          lastName: 'Doe',
          createdDate: testDate,
        );

        final projectId = await storageService.insertProject(project);
        final contactId = await storageService.insertContact(contact);

        await storageService.linkProjectContact(projectId, contactId);
        await storageService.linkProjectContact(projectId, contactId); // Duplicate

        final projectContacts = await storageService.getContactsForProject(projectId);
        expect(projectContacts.length, equals(1));
      });

      test('should return empty list for project with no contacts', () async {
        final project = Project(
          title: 'Test Project',
          createdDate: testDate,
          updatedDate: testDate,
        );

        final projectId = await storageService.insertProject(project);
        final projectContacts = await storageService.getContactsForProject(projectId);

        expect(projectContacts, isEmpty);
      });
    });

    group('Activity Operations', () {
      test('should insert and retrieve activities for a project', () async {
        final project = Project(
          title: 'Test Project',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final projectId = await storageService.insertProject(project);

        final activity1 = Activity(
          projectId: projectId,
          date: testDate,
          activity: 'First activity',
          createdDate: testDate,
        );
        final activity2 = Activity(
          projectId: projectId,
          date: testDate.add(Duration(days: 1)),
          activity: 'Second activity',
          createdDate: testDate,
        );

        final activityId1 = await storageService.insertActivity(activity1);
        final activityId2 = await storageService.insertActivity(activity2);

        expect(activityId1, equals(1));
        expect(activityId2, equals(2));

        final projectActivities = await storageService.getActivitiesForProject(projectId);
        expect(projectActivities.length, equals(2));
        expect(projectActivities[0].activity, equals('First activity'));
        expect(projectActivities[1].activity, equals('Second activity'));
      });

      test('should return empty list for project with no activities', () async {
        final project = Project(
          title: 'Test Project',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final projectId = await storageService.insertProject(project);

        final activities = await storageService.getActivitiesForProject(projectId);
        expect(activities, isEmpty);
      });

      test('should only return activities for specific project', () async {
        final project1 = Project(title: 'Project 1', createdDate: testDate, updatedDate: testDate);
        final project2 = Project(title: 'Project 2', createdDate: testDate, updatedDate: testDate);
        
        final projectId1 = await storageService.insertProject(project1);
        final projectId2 = await storageService.insertProject(project2);

        final activity1 = Activity(
          projectId: projectId1,
          date: testDate,
          activity: 'Activity for project 1',
          createdDate: testDate,
        );
        final activity2 = Activity(
          projectId: projectId2,
          date: testDate,
          activity: 'Activity for project 2',
          createdDate: testDate,
        );

        await storageService.insertActivity(activity1);
        await storageService.insertActivity(activity2);

        final project1Activities = await storageService.getActivitiesForProject(projectId1);
        final project2Activities = await storageService.getActivitiesForProject(projectId2);

        expect(project1Activities.length, equals(1));
        expect(project2Activities.length, equals(1));
        expect(project1Activities[0].activity, equals('Activity for project 1'));
        expect(project2Activities[0].activity, equals('Activity for project 2'));
      });
    });

    group('Document Operations', () {
      test('should insert and retrieve documents', () async {
        final project = Project(
          title: 'Test Project',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final projectId = await storageService.insertProject(project);

        final document = Document(
          projectId: projectId,
          title: 'Contract Document',
          filePath: '/path/to/contract.pdf',
          fileSize: 1024000,
          fileType: 'pdf',
          uploadDate: testDate,
        );

        final documentId = await storageService.insertDocument(document);
        expect(documentId, equals(1));

        final allDocuments = await storageService.getAllDocuments();
        expect(allDocuments.length, equals(1));
        expect(allDocuments[0].title, equals('Contract Document'));

        final projectDocuments = await storageService.getDocumentsForProject(projectId);
        expect(projectDocuments.length, equals(1));
        expect(projectDocuments[0].title, equals('Contract Document'));
      });

      test('should return empty list when no documents exist', () async {
        final documents = await storageService.getAllDocuments();
        expect(documents, isEmpty);
      });

      test('should return only documents for specific project', () async {
        final project1 = Project(title: 'Project 1', createdDate: testDate, updatedDate: testDate);
        final project2 = Project(title: 'Project 2', createdDate: testDate, updatedDate: testDate);
        
        final projectId1 = await storageService.insertProject(project1);
        final projectId2 = await storageService.insertProject(project2);

        final document1 = Document(
          projectId: projectId1,
          title: 'Document 1',
          filePath: '/path/to/document1.pdf',
          fileSize: 1024,
          fileType: 'pdf',
          uploadDate: testDate,
        );
        final document2 = Document(
          projectId: projectId2,
          title: 'Document 2',
          filePath: '/path/to/document2.pdf',
          fileSize: 2048,
          fileType: 'pdf',
          uploadDate: testDate,
        );

        await storageService.insertDocument(document1);
        await storageService.insertDocument(document2);

        final project1Documents = await storageService.getDocumentsForProject(projectId1);
        final project2Documents = await storageService.getDocumentsForProject(projectId2);

        expect(project1Documents.length, equals(1));
        expect(project2Documents.length, equals(1));
        expect(project1Documents[0].title, equals('Document 1'));
        expect(project2Documents[0].title, equals('Document 2'));
      });
    });

    group('Search Operations', () {
      test('should search across projects and contacts', () async {
        // Create test data
        final project = Project(
          title: 'Kitchen Renovation',
          description: 'Modern kitchen with new appliances',
          tags: 'renovation,kitchen,modern',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final contact = Contact(
          firstName: 'John',
          lastName: 'Kitchen',
          companyName: 'Kitchen Experts LLC',
          email: 'john@kitchenexperts.com',
          createdDate: testDate,
        );

        await storageService.insertProject(project);
        await storageService.insertContact(contact);

        // Search for 'kitchen'
        final results = await storageService.searchAll('kitchen');
        expect(results.length, equals(2));

        final projectResults = results.where((r) => r['type'] == 'project').toList();
        final contactResults = results.where((r) => r['type'] == 'contact').toList();

        expect(projectResults.length, equals(1));
        expect(contactResults.length, equals(1));
        expect(projectResults[0]['title'], equals('Kitchen Renovation'));
        expect(contactResults[0]['first_name'], equals('John'));
      });

      test('should be case insensitive', () async {
        final project = Project(
          title: 'Kitchen Renovation',
          createdDate: testDate,
          updatedDate: testDate,
        );
        await storageService.insertProject(project);

        final results = await storageService.searchAll('KITCHEN');
        expect(results.length, equals(1));
        expect(results[0]['title'], equals('Kitchen Renovation'));
      });

      test('should return empty results for no matches', () async {
        final project = Project(
          title: 'Kitchen Renovation',
          createdDate: testDate,
          updatedDate: testDate,
        );
        await storageService.insertProject(project);

        final results = await storageService.searchAll('bathroom');
        expect(results, isEmpty);
      });

      test('should search in multiple project fields', () async {
        final project1 = Project(
          title: 'Bathroom Remodel',
          description: 'Kitchen moved to new location',
          createdDate: testDate,
          updatedDate: testDate,
        );
        final project2 = Project(
          title: 'Garden Project',
          tags: 'kitchen,garden,outdoor',
          createdDate: testDate,
          updatedDate: testDate,
        );

        await storageService.insertProject(project1);
        await storageService.insertProject(project2);

        final results = await storageService.searchAll('kitchen');
        expect(results.length, equals(2));
      });

      test('should search in multiple contact fields', () async {
        final contact1 = Contact(
          firstName: 'Kitchen',
          lastName: 'Expert',
          createdDate: testDate,
        );
        final contact2 = Contact(
          firstName: 'John',
          lastName: 'Doe',
          companyName: 'Kitchen Solutions',
          createdDate: testDate,
        );
        final contact3 = Contact(
          firstName: 'Jane',
          lastName: 'Smith',
          email: 'jane@kitchen.com',
          createdDate: testDate,
        );

        await storageService.insertContact(contact1);
        await storageService.insertContact(contact2);
        await storageService.insertContact(contact3);

        final results = await storageService.searchAll('kitchen');
        expect(results.length, equals(3));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty storage gracefully', () async {
        final projects = await storageService.getAllProjects();
        final contacts = await storageService.getAllContacts();
        final documents = await storageService.getAllDocuments();
        final searchResults = await storageService.searchAll('test');

        expect(projects, isEmpty);
        expect(contacts, isEmpty);
        expect(documents, isEmpty);
        expect(searchResults, isEmpty);
      });

      test('should handle special characters in search', () async {
        final project = Project(
          title: 'Project with "quotes" & symbols',
          createdDate: testDate,
          updatedDate: testDate,
        );
        await storageService.insertProject(project);

        final results = await storageService.searchAll('quotes');
        expect(results.length, equals(1));
      });

      test('should handle very long strings', () async {
        final longDescription = 'A' * 1000; // 1000 character string
        final project = Project(
          title: 'Project with long description',
          description: longDescription,
          createdDate: testDate,
          updatedDate: testDate,
        );

        final projectId = await storageService.insertProject(project);
        final retrievedProject = await storageService.getProject(projectId);

        expect(retrievedProject, isNotNull);
        expect(retrievedProject!.description!.length, equals(1000));
      });
    });
  });
}