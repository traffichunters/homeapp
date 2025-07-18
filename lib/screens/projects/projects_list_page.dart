import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/contact.dart';
import '../../models/activity.dart';
import '../../models/document.dart';
import '../../services/storage_service.dart';
import 'single_project_page.dart';

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => ProjectsListPageState();
}

class ProjectsListPageState extends State<ProjectsListPage> {
  final StorageService _storageService = StorageService();
  List<Project> _projects = [];
  final Map<int, List<Contact>> _projectContacts = {};
  final Map<int, List<Activity>> _projectActivities = {};
  final Map<int, List<Document>> _projectDocuments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _storageService.getAllProjects();
      print('DEBUG: Loaded ${projects.length} projects');
      
      // Load related data for each project
      for (final project in projects) {
        if (project.id != null) {
          final contacts = await _storageService.getContactsForProject(project.id!);
          final activities = await _storageService.getActivitiesForProject(project.id!);
          final documents = await _storageService.getDocumentsForProject(project.id!);
          
          _projectContacts[project.id!] = contacts;
          _projectActivities[project.id!] = activities;
          _projectDocuments[project.id!] = documents;
        }
      }
      
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading projects: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
      }
    }
  }

  Future<void> _refreshProjects() async {
    setState(() {
      _isLoading = true;
      _projectContacts.clear();
      _projectActivities.clear();
      _projectDocuments.clear();
    });
    await _loadProjects();
  }

  // Public method to refresh projects from external callers
  Future<void> refreshProjects() async {
    await _refreshProjects();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _projects.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _refreshProjects,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return _buildProjectCard(project);
                  },
                ),
              );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first project',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(Project project) {
    final contacts = _projectContacts[project.id] ?? [];
    final activities = _projectActivities[project.id] ?? [];
    final documents = _projectDocuments[project.id] ?? [];
    
    // Get last activity date
    DateTime? lastActivityDate;
    if (activities.isNotEmpty) {
      lastActivityDate = activities
          .map((a) => a.date)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleProjectPage(project: project),
            ),
          ).then((_) => _refreshProjects());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project title
              Text(
                project.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              
              // Project description
              if (project.description != null && project.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    project.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Project stats row
              Row(
                children: [
                  // Activities count
                  _buildStatItem(
                    icon: Icons.event_note,
                    count: activities.length,
                    label: 'activities',
                  ),
                  const SizedBox(width: 16),
                  
                  // Documents count
                  _buildStatItem(
                    icon: Icons.attach_file,
                    count: documents.length,
                    label: 'documents',
                  ),
                  const SizedBox(width: 16),
                  
                  // Contacts count
                  _buildStatItem(
                    icon: Icons.people,
                    count: contacts.length,
                    label: 'contacts',
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Last activity date or updated date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    lastActivityDate != null
                        ? 'Last activity ${_formatDate(lastActivityDate)}'
                        : 'Updated ${_formatDate(project.updatedDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              
              // Associated contacts with avatars
              if (contacts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Contact avatars
                    ...contacts.take(3).map((contact) => 
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            _getContactInitials(contact),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Show count if more than 3 contacts
                    if (contacts.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${contacts.length - 3}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        contacts.take(3).map((c) => c.fullName).join(', ') +
                            (contacts.length > 3 ? ' +${contacts.length - 3} more' : ''),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Tags
              if (project.tags != null && project.tags!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: project.tags!.split(',').map((tag) {
                      return Chip(
                        label: Text(
                          tag.trim(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}