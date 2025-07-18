import 'package:flutter_test/flutter_test.dart';
import 'package:homeapp/models/contact.dart';

void main() {
  group('Contact Model Tests', () {
    late DateTime testDate;
    late Contact testContact;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testContact = Contact(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        companyName: 'ABC Construction',
        email: 'john.doe@example.com',
        phoneNumber: '+1-555-0123',
        url: 'https://www.abcconstruction.com',
        createdDate: testDate,
      );
    });

    test('should create Contact with all properties', () {
      expect(testContact.id, equals(1));
      expect(testContact.firstName, equals('John'));
      expect(testContact.lastName, equals('Doe'));
      expect(testContact.companyName, equals('ABC Construction'));
      expect(testContact.email, equals('john.doe@example.com'));
      expect(testContact.phoneNumber, equals('+1-555-0123'));
      expect(testContact.url, equals('https://www.abcconstruction.com'));
      expect(testContact.createdDate, equals(testDate));
    });

    test('should create Contact with minimal required properties', () {
      final minimalContact = Contact(
        firstName: 'Jane',
        lastName: 'Smith',
        createdDate: testDate,
      );

      expect(minimalContact.id, isNull);
      expect(minimalContact.firstName, equals('Jane'));
      expect(minimalContact.lastName, equals('Smith'));
      expect(minimalContact.companyName, isNull);
      expect(minimalContact.email, isNull);
      expect(minimalContact.phoneNumber, isNull);
      expect(minimalContact.url, isNull);
      expect(minimalContact.createdDate, equals(testDate));
    });

    test('should return correct fullName', () {
      expect(testContact.fullName, equals('John Doe'));
      
      final contactWithSpaces = Contact(
        firstName: ' Alice ',
        lastName: ' Johnson ',
        createdDate: testDate,
      );
      expect(contactWithSpaces.fullName, equals(' Alice   Johnson '));
    });

    test('should convert Contact to Map correctly', () {
      final map = testContact.toMap();

      expect(map['id'], equals(1));
      expect(map['first_name'], equals('John'));
      expect(map['last_name'], equals('Doe'));
      expect(map['company_name'], equals('ABC Construction'));
      expect(map['email'], equals('john.doe@example.com'));
      expect(map['phone_number'], equals('+1-555-0123'));
      expect(map['url'], equals('https://www.abcconstruction.com'));
      expect(map['created_date'], equals(testDate.toIso8601String()));
    });

    test('should convert Contact to Map with null values', () {
      final contactWithNulls = Contact(
        firstName: 'Test',
        lastName: 'User',
        createdDate: testDate,
      );
      final map = contactWithNulls.toMap();

      expect(map['id'], isNull);
      expect(map['first_name'], equals('Test'));
      expect(map['last_name'], equals('User'));
      expect(map['company_name'], isNull);
      expect(map['email'], isNull);
      expect(map['phone_number'], isNull);
      expect(map['url'], isNull);
      expect(map['created_date'], equals(testDate.toIso8601String()));
    });

    test('should create Contact from Map correctly', () {
      final map = {
        'id': 2,
        'first_name': 'Bob',
        'last_name': 'Wilson',
        'company_name': 'Wilson Plumbing',
        'email': 'bob@wilsonplumbing.com',
        'phone_number': '+1-555-9876',
        'url': 'https://wilsonplumbing.com',
        'created_date': testDate.toIso8601String(),
      };

      final contact = Contact.fromMap(map);

      expect(contact.id, equals(2));
      expect(contact.firstName, equals('Bob'));
      expect(contact.lastName, equals('Wilson'));
      expect(contact.companyName, equals('Wilson Plumbing'));
      expect(contact.email, equals('bob@wilsonplumbing.com'));
      expect(contact.phoneNumber, equals('+1-555-9876'));
      expect(contact.url, equals('https://wilsonplumbing.com'));
      expect(contact.createdDate, equals(testDate));
    });

    test('should create Contact from Map with null values', () {
      final map = {
        'id': null,
        'first_name': 'Simple',
        'last_name': 'Contact',
        'company_name': null,
        'email': null,
        'phone_number': null,
        'url': null,
        'created_date': testDate.toIso8601String(),
      };

      final contact = Contact.fromMap(map);

      expect(contact.id, isNull);
      expect(contact.firstName, equals('Simple'));
      expect(contact.lastName, equals('Contact'));
      expect(contact.companyName, isNull);
      expect(contact.email, isNull);
      expect(contact.phoneNumber, isNull);
      expect(contact.url, isNull);
      expect(contact.createdDate, equals(testDate));
    });

    test('should copy Contact with updated properties', () {
      final updatedContact = testContact.copyWith(
        firstName: 'Johnny',
        email: 'johnny.doe@newcompany.com',
        companyName: 'New Company LLC',
      );

      expect(updatedContact.id, equals(testContact.id));
      expect(updatedContact.firstName, equals('Johnny'));
      expect(updatedContact.lastName, equals(testContact.lastName));
      expect(updatedContact.companyName, equals('New Company LLC'));
      expect(updatedContact.email, equals('johnny.doe@newcompany.com'));
      expect(updatedContact.phoneNumber, equals(testContact.phoneNumber));
      expect(updatedContact.url, equals(testContact.url));
      expect(updatedContact.createdDate, equals(testContact.createdDate));
    });

    test('should copy Contact preserving existing values when no changes', () {
      final copiedContact = testContact.copyWith();

      expect(copiedContact.id, equals(testContact.id));
      expect(copiedContact.firstName, equals(testContact.firstName));
      expect(copiedContact.lastName, equals(testContact.lastName));
      expect(copiedContact.companyName, equals(testContact.companyName));
      expect(copiedContact.email, equals(testContact.email));
      expect(copiedContact.phoneNumber, equals(testContact.phoneNumber));
      expect(copiedContact.url, equals(testContact.url));
      expect(copiedContact.createdDate, equals(testContact.createdDate));
    });

    test('should handle toMap and fromMap round trip correctly', () {
      final map = testContact.toMap();
      final recreatedContact = Contact.fromMap(map);

      expect(recreatedContact.id, equals(testContact.id));
      expect(recreatedContact.firstName, equals(testContact.firstName));
      expect(recreatedContact.lastName, equals(testContact.lastName));
      expect(recreatedContact.companyName, equals(testContact.companyName));
      expect(recreatedContact.email, equals(testContact.email));
      expect(recreatedContact.phoneNumber, equals(testContact.phoneNumber));
      expect(recreatedContact.url, equals(testContact.url));
      expect(recreatedContact.createdDate, equals(testContact.createdDate));
      expect(recreatedContact.fullName, equals(testContact.fullName));
    });

    test('should throw FormatException for invalid date in fromMap', () {
      final invalidMap = {
        'id': 1,
        'first_name': 'Test',
        'last_name': 'User',
        'created_date': 'invalid-date',
      };

      expect(() => Contact.fromMap(invalidMap), throwsFormatException);
    });

    test('should handle edge cases for fullName getter', () {
      final contactWithEmptyNames = Contact(
        firstName: '',
        lastName: '',
        createdDate: testDate,
      );
      expect(contactWithEmptyNames.fullName, equals(' '));

      final contactWithSingleName = Contact(
        firstName: 'Madonna',
        lastName: '',
        createdDate: testDate,
      );
      expect(contactWithSingleName.fullName, equals('Madonna '));
    });
  });
}