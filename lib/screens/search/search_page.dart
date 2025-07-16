import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/contact.dart';
import '../../models/document.dart';
import '../../models/activity.dart';
import '../../services/storage_service.dart';
import '../../services/search_history_service.dart';
import '../projects/single_project_page.dart';
import '../contacts/single_contact_page.dart';
import '../documents/single_document_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final StorageService _storageService = StorageService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Project> _projects = [];
  List<Contact> _contacts = [];
  List<Document> _documents = [];
  List<Activity> _activities = [];
  
  List<Project> _filteredProjects = [];
  List<Contact> _filteredContacts = [];
  List<Document> _filteredDocuments = [];
  List<Activity> _filteredActivities = [];
  
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];
  
  bool _isLoading = false;
  bool _showSuggestions = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final projects = await _storageService.getAllProjects();
      final contacts = await _storageService.getAllContacts();
      final documents = await _storageService.getAllDocuments();
      final activities = await _storageService.getAllActivities();

      setState(() {
        _projects = projects;
        _contacts = contacts;
        _documents = documents;
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService.getSearchHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus && _searchQuery.isEmpty;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _showSuggestions = _searchFocusNode.hasFocus;
    });
    
    if (_searchQuery.isNotEmpty) {
      _loadSuggestions(_searchQuery);
      _performSearch(_searchQuery);
    } else {
      setState(() {
        _filteredProjects = [];
        _filteredContacts = [];
        _filteredDocuments = [];
        _filteredActivities = [];
        _searchSuggestions = [];
      });
    }
  }

  Future<void> _loadSuggestions(String query) async {
    if (query.trim().isEmpty) return;
    
    final suggestions = await _searchHistoryService.getSearchSuggestions(query);
    setState(() {
      _searchSuggestions = suggestions;
    });
  }

  Future<void> _performSearchWithQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
      _showSuggestions = false;
    });
    
    // Add to search history
    await _searchHistoryService.addSearchQuery(query);
    await _loadSearchHistory();
    
    _performSearch(query);
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProjects = [];
        _filteredContacts = [];
        _filteredDocuments = [];
        _filteredActivities = [];
      });
      return;
    }

    final searchLower = query.toLowerCase();

    setState(() {
      // Search projects
      _filteredProjects = _projects.where((project) {
        return project.title.toLowerCase().contains(searchLower) ||
               (project.description?.toLowerCase().contains(searchLower) ?? false) ||
               (project.tags?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      // Search contacts
      _filteredContacts = _contacts.where((contact) {
        return contact.firstName.toLowerCase().contains(searchLower) ||
               contact.lastName.toLowerCase().contains(searchLower) ||
               contact.fullName.toLowerCase().contains(searchLower) ||
               (contact.companyName?.toLowerCase().contains(searchLower) ?? false) ||
               (contact.email?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      // Search documents
      _filteredDocuments = _documents.where((document) {
        return document.title.toLowerCase().contains(searchLower) ||
               document.fileType.toLowerCase().contains(searchLower);
      }).toList();

      // Search activities
      _filteredActivities = _activities.where((activity) {
        return activity.activity.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search projects, contacts, documents, activities...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchHistory.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.history),
                              onPressed: () {
                                setState(() {
                                  _showSuggestions = !_showSuggestions;
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _showSuggestions = false;
                              });
                            },
                          ),
                        ],
                      )
                    : (_searchHistory.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.history),
                            onPressed: () {
                              setState(() {
                                _showSuggestions = !_showSuggestions;
                              });
                            },
                          )
                        : null),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  _performSearchWithQuery(query);
                }
              },
            ),
          ),
          
          // Search results or suggestions
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showSuggestions
                    ? _buildSuggestions()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current search suggestions
        if (_searchQuery.isNotEmpty && _searchSuggestions.isNotEmpty) ...[
          Text(
            'Suggestions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ..._searchSuggestions.map((suggestion) => _buildSuggestionItem(suggestion)),
          const SizedBox(height: 16),
        ],
        
        // Search history
        if (_searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _searchHistoryService.clearSearchHistory();
                  await _loadSearchHistory();
                },
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._searchHistory.map((query) => _buildHistoryItem(query)),
        ],
        
        // Empty state
        if (_searchHistory.isEmpty && _searchSuggestions.isEmpty) ...[
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Search across all content',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Projects • Contacts • Documents • Activities',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: const Icon(Icons.search, color: Colors.grey),
        title: Text(suggestion),
        trailing: const Icon(Icons.call_made, size: 16),
        onTap: () => _performSearchWithQuery(suggestion),
      ),
    );
  }

  Widget _buildHistoryItem(String query) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: const Icon(Icons.history, color: Colors.grey),
        title: Text(query),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 16),
          onPressed: () async {
            await _searchHistoryService.removeSearchQuery(query);
            await _loadSearchHistory();
          },
        ),
        onTap: () => _performSearchWithQuery(query),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchQuery.isEmpty) {
      return _buildSuggestions();
    }

    final totalResults = _filteredProjects.length +
        _filteredContacts.length +
        _filteredDocuments.length +
        _filteredActivities.length;

    if (totalResults == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '$totalResults result${totalResults == 1 ? '' : 's'} found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        
        // Projects section
        if (_filteredProjects.isNotEmpty) ...[
          _buildSectionHeader('Projects', _filteredProjects.length),
          ..._filteredProjects.map(_buildProjectItem),
          const SizedBox(height: 16),
        ],
        
        // Contacts section
        if (_filteredContacts.isNotEmpty) ...[
          _buildSectionHeader('Contacts', _filteredContacts.length),
          ..._filteredContacts.map(_buildContactItem),
          const SizedBox(height: 16),
        ],
        
        // Documents section
        if (_filteredDocuments.isNotEmpty) ...[
          _buildSectionHeader('Documents', _filteredDocuments.length),
          ..._filteredDocuments.map(_buildDocumentItem),
          const SizedBox(height: 16),
        ],
        
        // Activities section
        if (_filteredActivities.isNotEmpty) ...[
          _buildSectionHeader('Activities', _filteredActivities.length),
          ..._filteredActivities.map(_buildActivityItem),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.folder,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          project.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: project.description != null
            ? Text(
                project.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleProjectPage(project: project),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactItem(Contact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            _getContactInitials(contact),
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          contact.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: contact.companyName != null
            ? Text(contact.companyName!)
            : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleContactPage(contact: contact),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDocumentItem(Document document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getDocumentIcon(document.fileType),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_formatFileSize(document.fileSize)} • ${document.fileType.toUpperCase()}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleDocumentPage(document: document),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.event,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          activity.activity,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${_formatDate(activity.date)} • From project',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          // Navigate to the project that contains this activity
          final project = await _storageService.getProject(activity.projectId);
          if (project != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleProjectPage(project: project),
              ),
            );
          }
        },
      ),
    );
  }

  String _getContactInitials(Contact contact) {
    String initials = '';
    if (contact.firstName.isNotEmpty) {
      initials += contact.firstName[0].toUpperCase();
    }
    if (contact.lastName.isNotEmpty) {
      initials += contact.lastName[0].toUpperCase();
    }
    return initials.isEmpty ? '?' : initials;
  }

  IconData _getDocumentIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.attach_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}