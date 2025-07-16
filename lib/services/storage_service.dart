import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/contact.dart';
import '../models/activity.dart';
import '../models/document.dart';

class StorageService {
  static const String _projectsKey = 'projects';
  static const String _contactsKey = 'contacts';
  static const String _activitiesKey = 'activities';
  static const String _documentsKey = 'documents';
  static const String _projectContactsKey = 'project_contacts';

  // Projects
  Future<int> insertProject(Project project) async {
    final prefs = await SharedPreferences.getInstance();
    final projects = await getAllProjects();
    
    final newId = projects.isNotEmpty 
        ? projects.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1 
        : 1;
    
    final newProject = project.copyWith(id: newId);
    projects.add(newProject);
    
    await prefs.setString(_projectsKey, jsonEncode(
      projects.map((p) => p.toMap()).toList()
    ));
    
    return newId;
  }

  Future<List<Project>> getAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getString(_projectsKey);
    
    if (projectsJson == null) return [];
    
    final List<dynamic> projectsList = jsonDecode(projectsJson);
    return projectsList.map((json) => Project.fromMap(json)).toList();
  }

  Future<Project?> getProject(int id) async {
    final projects = await getAllProjects();
    try {
      return projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Contacts
  Future<int> insertContact(Contact contact) async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = await getAllContacts();
    
    final newId = contacts.isNotEmpty 
        ? contacts.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b) + 1 
        : 1;
    
    final newContact = contact.copyWith(id: newId);
    contacts.add(newContact);
    
    await prefs.setString(_contactsKey, jsonEncode(
      contacts.map((c) => c.toMap()).toList()
    ));
    
    return newId;
  }

  Future<List<Contact>> getAllContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString(_contactsKey);
    
    if (contactsJson == null) return [];
    
    final List<dynamic> contactsList = jsonDecode(contactsJson);
    return contactsList.map((json) => Contact.fromMap(json)).toList();
  }

  Future<Contact?> getContact(int id) async {
    final contacts = await getAllContacts();
    try {
      return contacts.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Contact>> getContactsForProject(int projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final projectContactsJson = prefs.getString(_projectContactsKey);
    
    if (projectContactsJson == null) return [];
    
    final List<dynamic> projectContactsList = jsonDecode(projectContactsJson);
    final contactIds = projectContactsList
        .where((pc) => pc['project_id'] == projectId)
        .map((pc) => pc['contact_id'] as int)
        .toList();
    
    final allContacts = await getAllContacts();
    return allContacts.where((c) => contactIds.contains(c.id)).toList();
  }

  Future<List<Project>> getProjectsForContact(int contactId) async {
    final prefs = await SharedPreferences.getInstance();
    final projectContactsJson = prefs.getString(_projectContactsKey);
    
    if (projectContactsJson == null) return [];
    
    final List<dynamic> projectContactsList = jsonDecode(projectContactsJson);
    final projectIds = projectContactsList
        .where((pc) => pc['contact_id'] == contactId)
        .map((pc) => pc['project_id'] as int)
        .toList();
    
    final allProjects = await getAllProjects();
    return allProjects.where((p) => projectIds.contains(p.id)).toList();
  }

  // Project-Contact linking
  Future<void> linkProjectContact(int projectId, int contactId) async {
    final prefs = await SharedPreferences.getInstance();
    final projectContactsJson = prefs.getString(_projectContactsKey) ?? '[]';
    final List<dynamic> projectContacts = jsonDecode(projectContactsJson);
    
    // Check if link already exists
    final exists = projectContacts.any((pc) => 
        pc['project_id'] == projectId && pc['contact_id'] == contactId);
    
    if (!exists) {
      projectContacts.add({
        'project_id': projectId,
        'contact_id': contactId,
      });
      
      await prefs.setString(_projectContactsKey, jsonEncode(projectContacts));
    }
  }

  // Activities
  Future<int> insertActivity(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey) ?? '[]';
    final List<dynamic> activities = jsonDecode(activitiesJson);
    
    final newId = activities.isNotEmpty 
        ? activities.map((a) => a['id'] ?? 0).reduce((a, b) => a > b ? a : b) + 1 
        : 1;
    
    final newActivity = activity.copyWith(id: newId);
    activities.add(newActivity.toMap());
    
    await prefs.setString(_activitiesKey, jsonEncode(activities));
    return newId;
  }

  Future<List<Activity>> getActivitiesForProject(int projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey) ?? '[]';
    final List<dynamic> activities = jsonDecode(activitiesJson);
    
    return activities
        .where((a) => a['project_id'] == projectId)
        .map((json) => Activity.fromMap(json))
        .toList();
  }

  Future<List<Activity>> getAllActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = prefs.getString(_activitiesKey) ?? '[]';
    final List<dynamic> activities = jsonDecode(activitiesJson);
    
    return activities
        .map((json) => Activity.fromMap(json))
        .toList();
  }

  // Documents
  Future<int> insertDocument(Document document) async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString(_documentsKey) ?? '[]';
    final List<dynamic> documents = jsonDecode(documentsJson);
    
    final newId = documents.isNotEmpty 
        ? documents.map((d) => d['id'] ?? 0).reduce((a, b) => a > b ? a : b) + 1 
        : 1;
    
    final newDocument = document.copyWith(id: newId);
    documents.add(newDocument.toMap());
    
    await prefs.setString(_documentsKey, jsonEncode(documents));
    return newId;
  }

  Future<List<Document>> getAllDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final documentsJson = prefs.getString(_documentsKey) ?? '[]';
    final List<dynamic> documents = jsonDecode(documentsJson);
    
    return documents.map((json) => Document.fromMap(json)).toList();
  }

  Future<List<Document>> getDocumentsForProject(int projectId) async {
    final documents = await getAllDocuments();
    return documents.where((d) => d.projectId == projectId).toList();
  }

  // Search
  Future<List<Map<String, dynamic>>> searchAll(String query) async {
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();
    
    // Search projects
    final projects = await getAllProjects();
    for (final project in projects) {
      if (project.title.toLowerCase().contains(lowerQuery) ||
          (project.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (project.tags?.toLowerCase().contains(lowerQuery) ?? false)) {
        results.add({...project.toMap(), 'type': 'project'});
      }
    }
    
    // Search contacts
    final contacts = await getAllContacts();
    for (final contact in contacts) {
      if (contact.firstName.toLowerCase().contains(lowerQuery) ||
          contact.lastName.toLowerCase().contains(lowerQuery) ||
          (contact.companyName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (contact.email?.toLowerCase().contains(lowerQuery) ?? false)) {
        results.add({...contact.toMap(), 'type': 'contact'});
      }
    }
    
    return results;
  }
}