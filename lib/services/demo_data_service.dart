import '../models/project.dart';
import '../models/contact.dart';
import '../models/activity.dart';
import '../models/document.dart';
import 'storage_service.dart';

class DemoDataService {
  final StorageService _storageService = StorageService();

  // Add comprehensive demo data
  Future<void> addDemoData() async {
    final now = DateTime.now();
    
    // Create demo contacts first
    final contacts = await _createDemoContacts(now);
    
    // Create demo projects and link them to contacts
    final projects = await _createDemoProjects(now, contacts);
    
    // Create demo activities for projects
    await _createDemoActivities(now, projects);
    
    // Create demo documents for projects
    await _createDemoDocuments(now, projects);
  }

  // Remove all data
  Future<void> removeAllData() async {
    // This would clear all SharedPreferences keys
    // We'll implement this by getting all data and clearing the storage
    
    final projects = await _storageService.getAllProjects();
    final contacts = await _storageService.getAllContacts();
    final activities = await _storageService.getAllActivities();
    final documents = await _storageService.getAllDocuments();
    
    // Clear all storage keys (this is a simplified approach)
    // In a real app, we'd have a clearAll method in StorageService
    print('Demo: Would clear ${projects.length} projects, ${contacts.length} contacts, ${activities.length} activities, ${documents.length} documents');
  }

  Future<List<Contact>> _createDemoContacts(DateTime now) async {
    final demoContacts = [
      Contact(
        firstName: 'John',
        lastName: 'Smith',
        companyName: 'Smith Construction',
        email: 'john@smithconstruction.com',
        phoneNumber: '(555) 123-4567',
        url: 'https://smithconstruction.com',
        starRating: 4.5,
        hourlyRate: 85.0,
        createdDate: now.subtract(const Duration(days: 30)),
      ),
      Contact(
        firstName: 'Sarah',
        lastName: 'Johnson',
        companyName: 'Johnson Electrical',
        email: 'sarah@johnsonelectric.com',
        phoneNumber: '(555) 987-6543',
        url: 'https://johnsonelectric.com',
        starRating: 5.0,
        hourlyRate: 95.0,
        createdDate: now.subtract(const Duration(days: 25)),
      ),
      Contact(
        firstName: 'Mike',
        lastName: 'Brown',
        companyName: 'Brown Plumbing',
        email: 'mike@brownplumbing.com',
        phoneNumber: '(555) 456-7890',
        starRating: 4.0,
        hourlyRate: 75.0,
        createdDate: now.subtract(const Duration(days: 20)),
      ),
      Contact(
        firstName: 'Lisa',
        lastName: 'Davis',
        companyName: 'Davis Interior Design',
        email: 'lisa@davisinterior.com',
        phoneNumber: '(555) 321-9876',
        url: 'https://davisinterior.com',
        starRating: 4.8,
        hourlyRate: 120.0,
        createdDate: now.subtract(const Duration(days: 15)),
      ),
      Contact(
        firstName: 'Robert',
        lastName: 'Wilson',
        companyName: 'Wilson Landscaping',
        email: 'robert@wilsonlandscaping.com',
        phoneNumber: '(555) 654-3210',
        starRating: 4.2,
        hourlyRate: 65.0,
        createdDate: now.subtract(const Duration(days: 10)),
      ),
    ];

    final savedContacts = <Contact>[];
    for (final contact in demoContacts) {
      final contactId = await _storageService.insertContact(contact);
      savedContacts.add(contact.copyWith(id: contactId));
    }
    
    return savedContacts;
  }

  Future<List<Project>> _createDemoProjects(DateTime now, List<Contact> contacts) async {
    final demoProjects = [
      Project(
        title: 'Kitchen Renovation',
        description: 'Complete kitchen remodel including new cabinets, countertops, and appliances. Focus on modern design with smart home integration.',
        createdDate: now.subtract(const Duration(days: 45)),
        updatedDate: now.subtract(const Duration(days: 2)),
        tags: 'renovation, kitchen, modern, smart home',
      ),
      Project(
        title: 'Bathroom Upgrade',
        description: 'Master bathroom renovation with walk-in shower, double vanity, and luxury finishes.',
        createdDate: now.subtract(const Duration(days: 30)),
        updatedDate: now.subtract(const Duration(days: 5)),
        tags: 'renovation, bathroom, luxury, master',
      ),
      Project(
        title: 'Home Office Setup',
        description: 'Convert spare bedroom into a functional home office with built-in shelving and proper lighting.',
        createdDate: now.subtract(const Duration(days: 20)),
        updatedDate: now.subtract(const Duration(days: 1)),
        tags: 'office, conversion, shelving, lighting',
      ),
      Project(
        title: 'Backyard Landscaping',
        description: 'Design and install new landscape featuring native plants, irrigation system, and outdoor lighting.',
        createdDate: now.subtract(const Duration(days: 35)),
        updatedDate: now.subtract(const Duration(days: 7)),
        tags: 'landscaping, outdoor, irrigation, native plants',
      ),
      Project(
        title: 'Electrical Panel Upgrade',
        description: 'Replace old electrical panel with modern 200-amp service and add GFCI outlets throughout house.',
        createdDate: now.subtract(const Duration(days: 15)),
        updatedDate: now.subtract(const Duration(days: 3)),
        tags: 'electrical, safety, upgrade, GFCI',
      ),
    ];

    final savedProjects = <Project>[];
    for (int i = 0; i < demoProjects.length; i++) {
      final project = demoProjects[i];
      final projectId = await _storageService.insertProject(project);
      final savedProject = project.copyWith(id: projectId);
      savedProjects.add(savedProject);
      
      // Link each project to 1-2 contacts
      if (i < contacts.length) {
        await _storageService.linkProjectContact(projectId, contacts[i].id!);
      }
      if (i > 0 && i + 1 < contacts.length) {
        await _storageService.linkProjectContact(projectId, contacts[i + 1].id!);
      }
    }
    
    return savedProjects;
  }

  Future<void> _createDemoActivities(DateTime now, List<Project> projects) async {
    final activityDescriptions = [
      'Initial consultation and project planning',
      'Materials ordered and delivery scheduled',
      'Site preparation and cleanup',
      'Installation work in progress',
      'Quality inspection completed',
      'Final walkthrough with contractor',
      'Project milestone reached',
      'Issue discovered and resolution planned',
      'Work completed on schedule',
      'Final payment processed',
    ];

    for (final project in projects) {
      if (project.id != null) {
        // Create 2-4 activities per project
        final activityCount = 2 + (project.id! % 3);
        for (int i = 0; i < activityCount; i++) {
          final activity = Activity(
            projectId: project.id!,
            date: now.subtract(Duration(days: 40 - (i * 10))),
            activity: activityDescriptions[i % activityDescriptions.length],
            createdDate: now.subtract(Duration(days: 39 - (i * 10))),
          );
          await _storageService.insertActivity(activity);
        }
      }
    }
  }

  Future<void> _createDemoDocuments(DateTime now, List<Project> projects) async {
    final documentTypes = [
      {'name': 'Project_Plans.pdf', 'type': 'pdf', 'size': 2500000},
      {'name': 'Before_Photo.jpg', 'type': 'jpg', 'size': 1200000},
      {'name': 'Material_List.xlsx', 'type': 'xlsx', 'size': 45000},
      {'name': 'Contract.pdf', 'type': 'pdf', 'size': 180000},
      {'name': 'Progress_Photo_1.jpg', 'type': 'jpg', 'size': 1800000},
      {'name': 'Progress_Photo_2.jpg', 'type': 'jpg', 'size': 1600000},
      {'name': 'Final_Invoice.pdf', 'type': 'pdf', 'size': 95000},
      {'name': 'Warranty_Info.pdf', 'type': 'pdf', 'size': 340000},
    ];

    for (final project in projects) {
      if (project.id != null) {
        // Create 1-3 documents per project
        final docCount = 1 + (project.id! % 3);
        for (int i = 0; i < docCount; i++) {
          final docInfo = documentTypes[i % documentTypes.length];
          final document = Document(
            projectId: project.id!,
            title: '${project.title}_${docInfo['name']}',
            filePath: '/demo/documents/${project.id}_${docInfo['name']}',
            fileSize: docInfo['size'] as int,
            fileType: docInfo['type'] as String,
            uploadDate: now.subtract(Duration(days: 30 - (i * 7))),
          );
          await _storageService.insertDocument(document);
        }
      }
    }
  }

  // Get data statistics
  Future<Map<String, int>> getDataStatistics() async {
    final projects = await _storageService.getAllProjects();
    final contacts = await _storageService.getAllContacts();
    final activities = await _storageService.getAllActivities();
    final documents = await _storageService.getAllDocuments();

    return {
      'projects': projects.length,
      'contacts': contacts.length,
      'activities': activities.length,
      'documents': documents.length,
    };
  }
}