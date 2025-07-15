import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/contact.dart';
import '../../models/activity.dart';
import '../../services/database_helper.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = false;
  
  // Contact form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _urlController = TextEditingController();
  
  // Activity and other data
  final List<Activity> _activities = [];
  final List<Contact> _existingContacts = [];
  Contact? _selectedContact;
  bool _showNewContactForm = false;
  String _tags = '';

  @override
  void initState() {
    super.initState();
    _loadExistingContacts();
  }

  Future<void> _loadExistingContacts() async {
    try {
      final contacts = await _databaseHelper.getAllContacts();
      setState(() {
        _existingContacts.clear();
        _existingContacts.addAll(contacts);
      });
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProject,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProjectInfoSection(),
              const SizedBox(height: 24),
              _buildContactSection(),
              const SizedBox(height: 24),
              _buildActivitiesSection(),
              const SizedBox(height: 24),
              _buildDocumentsSection(),
              const SizedBox(height: 24),
              _buildTagsSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Project Title *',
                hintText: 'e.g., Kitchen Renovation',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your project details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Contact',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Contact selection options
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Select Existing'),
                    value: false,
                    groupValue: _showNewContactForm,
                    onChanged: (value) {
                      setState(() {
                        _showNewContactForm = false;
                        _selectedContact = null;
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Add New'),
                    value: true,
                    groupValue: _showNewContactForm,
                    onChanged: (value) {
                      setState(() {
                        _showNewContactForm = true;
                        _selectedContact = null;
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (!_showNewContactForm)
              _buildExistingContactSelection()
            else
              _buildNewContactForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingContactSelection() {
    if (_existingContacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No existing contacts. Add your first contact using "Add New".',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<Contact>(
      value: _selectedContact,
      decoration: const InputDecoration(
        labelText: 'Select Contact',
        border: OutlineInputBorder(),
      ),
      items: _existingContacts.map((contact) {
        return DropdownMenuItem<Contact>(
          value: contact,
          child: Text('${contact.fullName}${contact.companyName != null ? ' (${contact.companyName})' : ''}'),
        );
      }).toList(),
      onChanged: (Contact? value) {
        setState(() {
          _selectedContact = value;
        });
      },
    );
  }

  Widget _buildNewContactForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  border: OutlineInputBorder(),
                ),
                validator: _showNewContactForm ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                } : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name *',
                  border: OutlineInputBorder(),
                ),
                validator: _showNewContactForm ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                } : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _companyNameController,
          decoration: const InputDecoration(
            labelText: 'Company Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: _showNewContactForm ? (value) {
            if (value != null && value.trim().isNotEmpty) {
              // Basic email validation
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          } : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Website URL',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
          validator: _showNewContactForm ? (value) {
            if (value != null && value.trim().isNotEmpty) {
              // Basic URL validation
              if (!RegExp(r'^https?://').hasMatch(value) && !value.startsWith('www.')) {
                return 'Please enter a valid URL (e.g., https://example.com)';
              }
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildActivitiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Activities section - Coming Soon'),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Documents section - Coming Soon'),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'renovation, kitchen, contractor',
                border: OutlineInputBorder(),
                helperText: 'Separate tags with commas',
              ),
              onChanged: (value) {
                _tags = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      
      // Create and save project
      final project = Project(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        createdDate: now,
        updatedDate: now,
        tags: _tags.trim().isEmpty ? null : _tags.trim(),
      );

      final projectId = await _databaseHelper.insertProject(project);

      // Handle contact if provided
      int? contactId;
      if (_showNewContactForm && _firstNameController.text.trim().isNotEmpty) {
        // Create new contact
        final contact = Contact(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          companyName: _companyNameController.text.trim().isEmpty 
              ? null 
              : _companyNameController.text.trim(),
          email: _emailController.text.trim().isEmpty 
              ? null 
              : _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty 
              ? null 
              : _phoneController.text.trim(),
          url: _urlController.text.trim().isEmpty 
              ? null 
              : _urlController.text.trim(),
          createdDate: now,
        );
        
        contactId = await _databaseHelper.insertContact(contact);
      } else if (!_showNewContactForm && _selectedContact != null) {
        // Use existing contact
        contactId = _selectedContact!.id;
      }

      // Link project and contact if contact exists
      if (contactId != null) {
        await _databaseHelper.linkProjectContact(projectId, contactId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating project: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}