import 'package:flutter_test/flutter_test.dart';
import 'package:homeapp/models/project.dart';

void main() {
  group('Project Model Tests', () {
    late DateTime testDate;
    late Project testProject;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testProject = Project(
        id: 1,
        title: 'Kitchen Renovation',
        description: 'Complete kitchen remodel with new cabinets and appliances',
        createdDate: testDate,
        updatedDate: testDate,
        tags: 'renovation,kitchen,cabinets',
      );
    });

    test('should create Project with all properties', () {
      expect(testProject.id, equals(1));
      expect(testProject.title, equals('Kitchen Renovation'));
      expect(testProject.description, equals('Complete kitchen remodel with new cabinets and appliances'));
      expect(testProject.createdDate, equals(testDate));
      expect(testProject.updatedDate, equals(testDate));
      expect(testProject.tags, equals('renovation,kitchen,cabinets'));
    });

    test('should create Project with minimal required properties', () {
      final minimalProject = Project(
        title: 'Simple Project',
        createdDate: testDate,
        updatedDate: testDate,
      );

      expect(minimalProject.id, isNull);
      expect(minimalProject.title, equals('Simple Project'));
      expect(minimalProject.description, isNull);
      expect(minimalProject.createdDate, equals(testDate));
      expect(minimalProject.updatedDate, equals(testDate));
      expect(minimalProject.tags, isNull);
    });

    test('should convert Project to Map correctly', () {
      final map = testProject.toMap();

      expect(map['id'], equals(1));
      expect(map['title'], equals('Kitchen Renovation'));
      expect(map['description'], equals('Complete kitchen remodel with new cabinets and appliances'));
      expect(map['created_date'], equals(testDate.toIso8601String()));
      expect(map['updated_date'], equals(testDate.toIso8601String()));
      expect(map['tags'], equals('renovation,kitchen,cabinets'));
    });

    test('should convert Project to Map with null values', () {
      final projectWithNulls = Project(
        title: 'Test Project',
        createdDate: testDate,
        updatedDate: testDate,
      );
      final map = projectWithNulls.toMap();

      expect(map['id'], isNull);
      expect(map['title'], equals('Test Project'));
      expect(map['description'], isNull);
      expect(map['created_date'], equals(testDate.toIso8601String()));
      expect(map['updated_date'], equals(testDate.toIso8601String()));
      expect(map['tags'], isNull);
    });

    test('should create Project from Map correctly', () {
      final map = {
        'id': 2,
        'title': 'Bathroom Remodel',
        'description': 'New bathroom fixtures and tiles',
        'created_date': testDate.toIso8601String(),
        'updated_date': testDate.toIso8601String(),
        'tags': 'bathroom,remodel,fixtures',
      };

      final project = Project.fromMap(map);

      expect(project.id, equals(2));
      expect(project.title, equals('Bathroom Remodel'));
      expect(project.description, equals('New bathroom fixtures and tiles'));
      expect(project.createdDate, equals(testDate));
      expect(project.updatedDate, equals(testDate));
      expect(project.tags, equals('bathroom,remodel,fixtures'));
    });

    test('should create Project from Map with null values', () {
      final map = {
        'id': null,
        'title': 'Simple Project',
        'description': null,
        'created_date': testDate.toIso8601String(),
        'updated_date': testDate.toIso8601String(),
        'tags': null,
      };

      final project = Project.fromMap(map);

      expect(project.id, isNull);
      expect(project.title, equals('Simple Project'));
      expect(project.description, isNull);
      expect(project.createdDate, equals(testDate));
      expect(project.updatedDate, equals(testDate));
      expect(project.tags, isNull);
    });

    test('should copy Project with updated properties', () {
      final updatedProject = testProject.copyWith(
        title: 'Updated Kitchen Renovation',
        description: 'Updated description with more details',
        tags: 'renovation,kitchen,modern',
      );

      expect(updatedProject.id, equals(testProject.id));
      expect(updatedProject.title, equals('Updated Kitchen Renovation'));
      expect(updatedProject.description, equals('Updated description with more details'));
      expect(updatedProject.createdDate, equals(testProject.createdDate));
      expect(updatedProject.updatedDate, equals(testProject.updatedDate));
      expect(updatedProject.tags, equals('renovation,kitchen,modern'));
    });

    test('should copy Project preserving existing values when no changes', () {
      final copiedProject = testProject.copyWith();

      expect(copiedProject.id, equals(testProject.id));
      expect(copiedProject.title, equals(testProject.title));
      expect(copiedProject.description, equals(testProject.description));
      expect(copiedProject.createdDate, equals(testProject.createdDate));
      expect(copiedProject.updatedDate, equals(testProject.updatedDate));
      expect(copiedProject.tags, equals(testProject.tags));
    });

    test('should handle toMap and fromMap round trip correctly', () {
      final map = testProject.toMap();
      final recreatedProject = Project.fromMap(map);

      expect(recreatedProject.id, equals(testProject.id));
      expect(recreatedProject.title, equals(testProject.title));
      expect(recreatedProject.description, equals(testProject.description));
      expect(recreatedProject.createdDate, equals(testProject.createdDate));
      expect(recreatedProject.updatedDate, equals(testProject.updatedDate));
      expect(recreatedProject.tags, equals(testProject.tags));
    });

    test('should throw FormatException for invalid date in fromMap', () {
      final invalidMap = {
        'id': 1,
        'title': 'Test Project',
        'created_date': 'invalid-date',
        'updated_date': testDate.toIso8601String(),
      };

      expect(() => Project.fromMap(invalidMap), throwsFormatException);
    });
  });
}