import 'package:flutter/material.dart';
import '../../models/document.dart';
import '../../services/storage_service.dart';
import '../../services/thumbnail_service.dart';
import 'single_document_page.dart';

class DocumentsListPage extends StatefulWidget {
  const DocumentsListPage({super.key});

  @override
  State<DocumentsListPage> createState() => _DocumentsListPageState();
}

class _DocumentsListPageState extends State<DocumentsListPage> {
  final StorageService _storageService = StorageService();
  List<Document> _documents = [];
  bool _isLoading = true;
  bool _isGridView = false;
  bool _isSelectionMode = false;
  Set<int> _selectedDocumentIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final documents = await _storageService.getAllDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading documents: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode 
            ? Text('${_selectedDocumentIds.length} selected')
            : const Text('Documents'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedDocumentIds.clear();
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
                      if (_selectedDocumentIds.length == _documents.length) {
                        _selectedDocumentIds.clear();
                      } else {
                        _selectedDocumentIds = _documents.where((doc) => doc.id != null).map((doc) => doc.id!).toSet();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _selectedDocumentIds.isEmpty ? null : () => _deleteSelectedDocuments(),
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
                IconButton(
                  icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                  tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
                ),
              ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildDocumentsList(),
    );
  }

  Widget _buildDocumentsList() {
    final List<Document> documents = _documents;

    if (documents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No documents found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add documents through the Create Project page',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return _isGridView
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return _buildDocumentGridItem(context, document);
            },
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              return _buildDocumentListItem(context, document);
            },
          );
  }

  Widget _buildDocumentListItem(BuildContext context, Document document) {
    final isSelected = _selectedDocumentIds.contains(document.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            _toggleDocumentSelection(document);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleDocumentPage(document: document),
              ),
            );
          }
        },
        onLongPress: () {
          if (!_isSelectionMode) {
            setState(() {
              _isSelectionMode = true;
              _selectedDocumentIds.add(document.id!);
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
                // Selection checkbox or thumbnail
                if (_isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (selected) => _toggleDocumentSelection(document),
                  )
                else
                  // Document thumbnail
                  ThumbnailService.generateListThumbnail(
                    document.filePath,
                    document.fileType,
                  ),
                const SizedBox(width: 16),
                // Document details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatFileSize(document.fileSize)} • ${document.fileType.toUpperCase()}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded ${_formatDate(document.uploadDate)}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                // Arrow icon or selection indicator
                if (!_isSelectionMode)
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400])
                else if (isSelected)
                  Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentGridItem(BuildContext context, Document document) {
    final isSelected = _selectedDocumentIds.contains(document.id);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            _toggleDocumentSelection(document);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SingleDocumentPage(document: document),
              ),
            );
          }
        },
        onLongPress: () {
          if (!_isSelectionMode) {
            setState(() {
              _isSelectionMode = true;
              _selectedDocumentIds.add(document.id!);
            });
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Document thumbnail (larger for grid)
                    Expanded(
                      child: Center(
                        child: FutureBuilder<Widget>(
                          future: ThumbnailService.generateThumbnail(
                            document.filePath,
                            document.fileType,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            } else {
                              return ThumbnailService.buildLoadingThumbnail(size: 100);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Document title
                    Text(
                      document.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // File info
                    Text(
                      '${_formatFileSize(document.fileSize)} • ${document.fileType.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Upload date
                    Text(
                      'Uploaded ${_formatDate(document.uploadDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Selection indicator
              if (_isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (selected) => _toggleDocumentSelection(document),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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

  void _toggleDocumentSelection(Document document) {
    setState(() {
      if (_selectedDocumentIds.contains(document.id)) {
        _selectedDocumentIds.remove(document.id);
      } else {
        _selectedDocumentIds.add(document.id!);
      }
    });
  }

  void _deleteSelectedDocuments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Documents'),
        content: Text(
          'Are you sure you want to delete ${_selectedDocumentIds.length} document${_selectedDocumentIds.length == 1 ? '' : 's'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final deletedCount = _selectedDocumentIds.length;
              
              // Remove selected documents from the list
              setState(() {
                _documents.removeWhere((doc) => _selectedDocumentIds.contains(doc.id));
                _selectedDocumentIds.clear();
                _isSelectionMode = false;
              });
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$deletedCount document${deletedCount == 1 ? '' : 's'} deleted'),
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
