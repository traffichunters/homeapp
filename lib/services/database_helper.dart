import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project.dart';
import '../models/contact.dart';
import '../models/activity.dart';
import '../models/document.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'house_projects.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to contacts table
      await db.execute('ALTER TABLE contacts ADD COLUMN star_rating REAL');
      await db.execute('ALTER TABLE contacts ADD COLUMN hourly_rate REAL');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // Projects table
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        created_date TEXT NOT NULL,
        updated_date TEXT NOT NULL,
        tags TEXT
      )
    ''');

    // Contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        company_name TEXT,
        email TEXT,
        phone_number TEXT,
        url TEXT,
        star_rating REAL,
        hourly_rate REAL,
        created_date TEXT NOT NULL
      )
    ''');

    // Activities table
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        activity TEXT NOT NULL,
        created_date TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Documents table
    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        file_type TEXT NOT NULL,
        thumbnail_path TEXT,
        upload_date TEXT NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
      )
    ''');

    // Project_Contacts junction table
    await db.execute('''
      CREATE TABLE project_contacts (
        project_id INTEGER NOT NULL,
        contact_id INTEGER NOT NULL,
        PRIMARY KEY (project_id, contact_id),
        FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
  }

  // Project CRUD operations
  Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert('projects', project.toMap());
  }

  Future<List<Project>> getAllProjects() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      orderBy: 'updated_date DESC',
    );
    return List.generate(maps.length, (i) => Project.fromMap(maps[i]));
  }

  Future<Project?> getProject(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateProject(Project project) async {
    final db = await database;
    return await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete(
      'projects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Contact CRUD operations
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      orderBy: 'first_name ASC',
    );
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  Future<Contact?> getContact(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Contact>> getContactsForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.* FROM contacts c
      INNER JOIN project_contacts pc ON c.id = pc.contact_id
      WHERE pc.project_id = ?
      ORDER BY c.first_name ASC
    ''', [projectId]);
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }

  // Activity CRUD operations
  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> getActivitiesForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  // Document CRUD operations
  Future<int> insertDocument(Document document) async {
    final db = await database;
    return await db.insert('documents', document.toMap());
  }

  Future<List<Document>> getAllDocuments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      orderBy: 'upload_date DESC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  Future<Document?> getDocument(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Document.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Document>> getDocumentsForProject(int projectId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'upload_date DESC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  // Project-Contact relationship operations
  Future<void> linkProjectContact(int projectId, int contactId) async {
    final db = await database;
    await db.insert(
      'project_contacts',
      {'project_id': projectId, 'contact_id': contactId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> unlinkProjectContact(int projectId, int contactId) async {
    final db = await database;
    await db.delete(
      'project_contacts',
      where: 'project_id = ? AND contact_id = ?',
      whereArgs: [projectId, contactId],
    );
  }

  // Search operations
  Future<List<Map<String, dynamic>>> searchAll(String query) async {
    final db = await database;
    final String searchQuery = '%$query%';
    
    List<Map<String, dynamic>> results = [];
    
    // Search projects
    final projectResults = await db.query(
      'projects',
      where: 'title LIKE ? OR description LIKE ? OR tags LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery],
    );
    for (var result in projectResults) {
      results.add({...result, 'type': 'project'});
    }
    
    // Search contacts
    final contactResults = await db.query(
      'contacts',
      where: 'first_name LIKE ? OR last_name LIKE ? OR company_name LIKE ? OR email LIKE ?',
      whereArgs: [searchQuery, searchQuery, searchQuery, searchQuery],
    );
    for (var result in contactResults) {
      results.add({...result, 'type': 'contact'});
    }
    
    // Search documents
    final documentResults = await db.query(
      'documents',
      where: 'title LIKE ?',
      whereArgs: [searchQuery],
    );
    for (var result in documentResults) {
      results.add({...result, 'type': 'document'});
    }
    
    // Search activities
    final activityResults = await db.query(
      'activities',
      where: 'activity LIKE ?',
      whereArgs: [searchQuery],
    );
    for (var result in activityResults) {
      results.add({...result, 'type': 'activity'});
    }
    
    return results;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}