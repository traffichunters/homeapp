import 'package:flutter/material.dart';
import '../../models/contact.dart';
import '../../services/storage_service.dart';
import 'single_contact_page.dart';

class ContactsListPage extends StatefulWidget {
  const ContactsListPage({super.key});

  @override
  State<ContactsListPage> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends State<ContactsListPage> {
  final StorageService _storageService = StorageService();
  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<int> _selectedContactIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await _storageService.getAllContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contacts: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode 
            ? Text('${_selectedContactIds.length} selected')
            : const Text('Contacts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedContactIds.clear();
                  });
                },
              )
            : null,
        actions: _isSelectionMode 
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    setState(() {
                      if (_selectedContactIds.length == _contacts.length) {
                        _selectedContactIds.clear();
                      } else {
                        _selectedContactIds = _contacts.where((contact) => contact.id != null).map((contact) => contact.id!).toSet();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _selectedContactIds.isEmpty ? null : () => _deleteSelectedContacts(),
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: () {
                    setState(() {
                      _isSelectionMode = true;
                    });
                  },
                  tooltip: 'Select items',
                ),
              ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildContactsList(),
    );
  }

  Widget _buildContactsList() {
    if (_contacts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No contacts found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add contacts through the Create Project page',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return _buildContactCard(contact);
      },
    );
  }

  Widget _buildContactCard(Contact contact) {
    final isSelected = _selectedContactIds.contains(contact.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            _toggleContactSelection(contact);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleContactPage(contact: contact),
              ),
            );
          }
        },
        onLongPress: () {
          if (!_isSelectionMode) {
            setState(() {
              _isSelectionMode = true;
              _selectedContactIds.add(contact.id!);
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Selection checkbox or contact avatar
                if (_isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (selected) => _toggleContactSelection(contact),
                  )
                else
                  // Contact avatar
                  _buildContactAvatar(contact),
                const SizedBox(width: 16),
                // Contact details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (contact.companyName != null && contact.companyName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          contact.companyName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Star rating display
                      _buildStarRating(contact.starRating),
                      const SizedBox(height: 4),
                      // Hourly rate display
                      if (contact.hourlyRate != null) ...[
                        Text(
                          '\$${contact.hourlyRate!.toStringAsFixed(0)}/hour',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Arrow icon or selection indicator
                if (!_isSelectionMode)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  )
                else if (isSelected)
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactAvatar(Contact contact) {
    // Generate avatar based on contact type
    final bool isCompany = contact.companyName != null && contact.companyName!.isNotEmpty;
    final IconData avatarIcon = isCompany ? Icons.business : Icons.person;
    final String initials = _getInitials(contact);

    return CircleAvatar(
      radius: 24,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            )
          : Icon(
              avatarIcon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
    );
  }

  String _getInitials(Contact contact) {
    final firstName = contact.firstName.trim();
    final lastName = contact.lastName.trim();
    
    if (firstName.isEmpty && lastName.isEmpty) return '';
    
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0].toUpperCase();
    if (lastName.isNotEmpty) initials += lastName[0].toUpperCase();
    
    return initials;
  }

  Widget _buildStarRating(double? rating) {
    if (rating == null) {
      return Row(
        children: [
          Icon(Icons.star_border, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 4),
          Text(
            'No rating',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      );
    }

    final int fullStars = rating.floor();
    final bool hasHalfStar = (rating - fullStars) >= 0.5;
    final int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        // Full stars
        ...List.generate(fullStars, (index) => Icon(
          Icons.star,
          size: 16,
          color: Colors.amber[600],
        )),
        // Half star
        if (hasHalfStar)
          Icon(
            Icons.star_half,
            size: 16,
            color: Colors.amber[600],
          ),
        // Empty stars
        ...List.generate(emptyStars, (index) => Icon(
          Icons.star_border,
          size: 16,
          color: Colors.grey[400],
        )),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContactIds.contains(contact.id)) {
        _selectedContactIds.remove(contact.id);
      } else {
        _selectedContactIds.add(contact.id!);
      }
    });
  }

  void _deleteSelectedContacts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contacts'),
        content: Text(
          'Are you sure you want to delete ${_selectedContactIds.length} contact${_selectedContactIds.length == 1 ? '' : 's'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final deletedCount = _selectedContactIds.length;
              
              // Remove selected contacts from the list
              setState(() {
                _contacts.removeWhere((contact) => _selectedContactIds.contains(contact.id));
                _selectedContactIds.clear();
                _isSelectionMode = false;
              });
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$deletedCount contact${deletedCount == 1 ? '' : 's'} deleted'),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}