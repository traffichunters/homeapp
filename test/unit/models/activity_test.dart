import 'package:flutter_test/flutter_test.dart';
import 'package:homeapp/models/activity.dart';

void main() {
  group('Activity Model Tests', () {
    late DateTime testDate;
    late DateTime activityDate;
    late Activity testActivity;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      activityDate = DateTime(2024, 1, 10, 14, 0);
      testActivity = Activity(
        id: 1,
        projectId: 5,
        date: activityDate,
        activity: 'Met with contractor for initial estimate',
        createdDate: testDate,
      );
    });

    test('should create Activity with all properties', () {
      expect(testActivity.id, equals(1));
      expect(testActivity.projectId, equals(5));
      expect(testActivity.date, equals(activityDate));
      expect(testActivity.activity, equals('Met with contractor for initial estimate'));
      expect(testActivity.createdDate, equals(testDate));
    });

    test('should create Activity with minimal required properties', () {
      final minimalActivity = Activity(
        projectId: 10,
        date: activityDate,
        activity: 'Simple activity',
        createdDate: testDate,
      );

      expect(minimalActivity.id, isNull);
      expect(minimalActivity.projectId, equals(10));
      expect(minimalActivity.date, equals(activityDate));
      expect(minimalActivity.activity, equals('Simple activity'));
      expect(minimalActivity.createdDate, equals(testDate));
    });

    test('should convert Activity to Map correctly', () {
      final map = testActivity.toMap();

      expect(map['id'], equals(1));
      expect(map['project_id'], equals(5));
      expect(map['date'], equals(activityDate.toIso8601String()));
      expect(map['activity'], equals('Met with contractor for initial estimate'));
      expect(map['created_date'], equals(testDate.toIso8601String()));
    });

    test('should convert Activity to Map with null id', () {
      final activityWithoutId = Activity(
        projectId: 3,
        date: activityDate,
        activity: 'Test activity',
        createdDate: testDate,
      );
      final map = activityWithoutId.toMap();

      expect(map['id'], isNull);
      expect(map['project_id'], equals(3));
      expect(map['date'], equals(activityDate.toIso8601String()));
      expect(map['activity'], equals('Test activity'));
      expect(map['created_date'], equals(testDate.toIso8601String()));
    });

    test('should create Activity from Map correctly', () {
      final map = {
        'id': 2,
        'project_id': 7,
        'date': activityDate.toIso8601String(),
        'activity': 'Purchased materials from hardware store',
        'created_date': testDate.toIso8601String(),
      };

      final activity = Activity.fromMap(map);

      expect(activity.id, equals(2));
      expect(activity.projectId, equals(7));
      expect(activity.date, equals(activityDate));
      expect(activity.activity, equals('Purchased materials from hardware store'));
      expect(activity.createdDate, equals(testDate));
    });

    test('should create Activity from Map with null id', () {
      final map = {
        'id': null,
        'project_id': 12,
        'date': activityDate.toIso8601String(),
        'activity': 'Planning phase completed',
        'created_date': testDate.toIso8601String(),
      };

      final activity = Activity.fromMap(map);

      expect(activity.id, isNull);
      expect(activity.projectId, equals(12));
      expect(activity.date, equals(activityDate));
      expect(activity.activity, equals('Planning phase completed'));
      expect(activity.createdDate, equals(testDate));
    });

    test('should copy Activity with updated properties', () {
      final newDate = DateTime(2024, 2, 1, 9, 0);
      final updatedActivity = testActivity.copyWith(
        activity: 'Updated activity description',
        date: newDate,
        projectId: 8,
      );

      expect(updatedActivity.id, equals(testActivity.id));
      expect(updatedActivity.projectId, equals(8));
      expect(updatedActivity.date, equals(newDate));
      expect(updatedActivity.activity, equals('Updated activity description'));
      expect(updatedActivity.createdDate, equals(testActivity.createdDate));
    });

    test('should copy Activity without changing original', () {
      final copiedActivity = testActivity.copyWith(
        activity: 'Different activity',
      );

      expect(testActivity.activity, equals('Met with contractor for initial estimate'));
      expect(copiedActivity.activity, equals('Different activity'));
      expect(copiedActivity.id, equals(testActivity.id));
      expect(copiedActivity.projectId, equals(testActivity.projectId));
      expect(copiedActivity.date, equals(testActivity.date));
      expect(copiedActivity.createdDate, equals(testActivity.createdDate));
    });

    test('should handle toMap and fromMap round trip correctly', () {
      final map = testActivity.toMap();
      final recreatedActivity = Activity.fromMap(map);

      expect(recreatedActivity.id, equals(testActivity.id));
      expect(recreatedActivity.projectId, equals(testActivity.projectId));
      expect(recreatedActivity.date, equals(testActivity.date));
      expect(recreatedActivity.activity, equals(testActivity.activity));
      expect(recreatedActivity.createdDate, equals(testActivity.createdDate));
    });

    test('should throw FormatException for invalid date in fromMap', () {
      final invalidMap = {
        'id': 1,
        'project_id': 5,
        'date': 'invalid-date',
        'activity': 'Test activity',
        'created_date': testDate.toIso8601String(),
      };

      expect(() => Activity.fromMap(invalidMap), throwsFormatException);
    });

    test('should throw FormatException for invalid created_date in fromMap', () {
      final invalidMap = {
        'id': 1,
        'project_id': 5,
        'date': activityDate.toIso8601String(),
        'activity': 'Test activity',
        'created_date': 'invalid-date',
      };

      expect(() => Activity.fromMap(invalidMap), throwsFormatException);
    });

    test('should handle different date formats correctly', () {
      final futureDate = DateTime(2025, 12, 25, 18, 30);
      final pastDate = DateTime(2020, 6, 15, 8, 45);

      final activityWithFutureDate = Activity(
        projectId: 1,
        date: futureDate,
        activity: 'Scheduled future work',
        createdDate: testDate,
      );

      final activityWithPastDate = Activity(
        projectId: 2,
        date: pastDate,
        activity: 'Historical activity log',
        createdDate: testDate,
      );

      expect(activityWithFutureDate.date, equals(futureDate));
      expect(activityWithPastDate.date, equals(pastDate));
      
      // Test round trip with different dates
      final futureMap = activityWithFutureDate.toMap();
      final recreatedFuture = Activity.fromMap(futureMap);
      expect(recreatedFuture.date, equals(futureDate));

      final pastMap = activityWithPastDate.toMap();
      final recreatedPast = Activity.fromMap(pastMap);
      expect(recreatedPast.date, equals(pastDate));
    });

    test('should handle empty and long activity descriptions', () {
      final emptyActivity = Activity(
        projectId: 1,
        date: activityDate,
        activity: '',
        createdDate: testDate,
      );

      final longActivity = Activity(
        projectId: 2,
        date: activityDate,
        activity: 'This is a very long activity description that contains multiple sentences and detailed information about what was accomplished during this particular activity. It includes specific details about materials used, people involved, timeline considerations, and outcomes achieved.',
        createdDate: testDate,
      );

      expect(emptyActivity.activity, equals(''));
      expect(longActivity.activity.length, greaterThan(100));

      // Test serialization with edge cases
      final emptyMap = emptyActivity.toMap();
      final recreatedEmpty = Activity.fromMap(emptyMap);
      expect(recreatedEmpty.activity, equals(''));

      final longMap = longActivity.toMap();
      final recreatedLong = Activity.fromMap(longMap);
      expect(recreatedLong.activity, equals(longActivity.activity));
    });
  });
}