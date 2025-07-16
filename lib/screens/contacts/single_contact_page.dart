import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/contact.dart';
import '../../models/project.dart';
import '../../services/storage_service.dart';
import '../projects/single_project_page.dart';

class SingleContactPage extends StatefulWidget {
  final Contact contact;

  const SingleContactPage({super.key, required this.contact});

  @override
  State<SingleContactPage> createState() => _SingleContactPageState();
}

class _SingleContactPageState extends State<SingleContactPage> {
  final StorageService _storageService = StorageService();
  List<Project> _associatedProjects = [];
  bool _isLoadingProjects = false;

  @override
  void initState() {
    super.initState();
    _loadAssociatedProjects();
  }

  Future<void> _loadAssociatedProjects() async {
    if (widget.contact.id == null) return;
    
    setState(() {
      _isLoadingProjects = true;
    });

    try {
      final projects = await _storageService.getProjectsForContact(widget.contact.id!);
      setState(() {
        _associatedProjects = projects;
        _isLoadingProjects = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProjects = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading projects: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact.fullName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactHeader(context),
            const SizedBox(height: 24),
            _buildContactDetails(context),
            const SizedBox(height: 24),
            _buildAssociatedProjects(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                widget.contact.firstName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contact.fullName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.contact.companyName != null && widget.contact.companyName!.isNotEmpty)
                    Text(
                      widget.contact.companyName!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDetails(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.contact.email != null && widget.contact.email!.isNotEmpty)
              _buildContactItem(
                context,
                Icons.email,
                'Email',
                widget.contact.email!,
                () => _launchEmail(widget.contact.email!),
              ),
            if (widget.contact.phoneNumber != null && widget.contact.phoneNumber!.isNotEmpty)
              _buildContactItem(
                context,
                Icons.phone,
                'Phone',
                widget.contact.phoneNumber!,
                () => _launchPhone(widget.contact.phoneNumber!),
              ),
            if (widget.contact.url != null && widget.contact.url!.isNotEmpty)
              _buildContactItem(
                context,
                Icons.link,
                'Website',
                widget.contact.url!,
                () => _launchUrl(widget.contact.url!),
              ),
            if (widget.contact.starRating != null)
              _buildContactItem(
                context,
                Icons.star,
                'Rating',
                '${widget.contact.starRating!.toStringAsFixed(1)} stars',
                null,
              ),
            if (widget.contact.hourlyRate != null)
              _buildContactItem(
                context,
                Icons.attach_money,
                'Hourly Rate',
                '\$${widget.contact.hourlyRate!.toStringAsFixed(0)}/hour',
                null,
              ),
            _buildContactItem(
              context,
              Icons.calendar_today,
              'Added',
              _formatDate(widget.contact.createdDate),
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssociatedProjects(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Associated Projects',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoadingProjects)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_associatedProjects.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This contact is not associated with any projects yet.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...(_associatedProjects.map((project) => _buildProjectItem(context, project)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleProjectPage(project: project),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (project.description != null && project.description!.isNotEmpty)
                      Text(
                        project.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback? onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.open_in_new,
                  color: Colors.grey[400],
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}