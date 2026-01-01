import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/image_storage_service.dart';
import '../../services/firestore_service.dart';
import '../edit_document_page.dart';

class _DocumentWithMetadata {
  final File file;
  final String? title;
  final String? tags;
  final String? folder;

  _DocumentWithMetadata({
    required this.file,
    this.title,
    this.tags,
    this.folder,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ImageStorageService _imageStorage = ImageStorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  List<_DocumentWithMetadata> _allDocuments = [];
  List<_DocumentWithMetadata> _filteredDocuments = [];
  Set<String> _selectedTags = {};
  List<String> _availableTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllDocuments();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllDocuments() async {
    // Show UI immediately with files (fast)
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all files first (fast, local operation)
      final files = await _imageStorage.getAllDocuments();
      
      // Sort by modification date (newest first)
      files.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });

      // Show documents immediately without metadata
      final documentsWithMetadata = files.map((file) {
        return _DocumentWithMetadata(
          file: file,
          title: null,
          tags: null,
          folder: null,
        );
      }).toList();

      setState(() {
        _allDocuments = documentsWithMetadata;
        _filteredDocuments = documentsWithMetadata;
        _isLoading = false;
      });
      
      // Load metadata in background (non-blocking)
      _loadMetadataInBackground(files);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMetadataInBackground(List<File> files) async {
    try {
      // Get documents metadata from Firestore (background)
      final querySnapshot = await _firestoreService.getCollection('documents');
      final Map<String, Map<String, dynamic>> docMetadata = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final filePath = data['filePath'] as String?;
          if (filePath != null && filePath.isNotEmpty) {
            docMetadata[filePath] = {
              'title': data['title'] ?? '',
              'tags': data['tags'] ?? '',
              'folder': data['folder'] ?? 'General',
            };
          }
        }
      }

      // Update existing documents with metadata (preserve order, no flicker)
      final Map<String, _DocumentWithMetadata> documentsMap = {};
      for (var doc in _allDocuments) {
        documentsMap[doc.file.path] = doc;
      }

      // Update metadata for existing documents
      for (var file in files) {
        final metadata = docMetadata[file.path];
        if (metadata != null && documentsMap.containsKey(file.path)) {
          documentsMap[file.path] = _DocumentWithMetadata(
            file: file,
            title: metadata['title'],
            tags: metadata['tags'],
            folder: metadata['folder'],
          );
        } else if (!documentsMap.containsKey(file.path)) {
          // New file found, add it
          documentsMap[file.path] = _DocumentWithMetadata(
            file: file,
            title: metadata?['title'],
            tags: metadata?['tags'],
            folder: metadata?['folder'],
          );
        }
      }

      // Convert back to list preserving order
      final updatedDocuments = files.map((file) {
        return documentsMap[file.path] ?? _DocumentWithMetadata(
          file: file,
          title: docMetadata[file.path]?['title'],
          tags: docMetadata[file.path]?['tags'],
          folder: docMetadata[file.path]?['folder'],
        );
      }).toList();

      // Extract all unique tags
      final Set<String> allTags = {};
      for (var doc in updatedDocuments) {
        if (doc.tags != null && doc.tags!.isNotEmpty) {
          final tags = doc.tags!
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty)
              .toList();
          allTags.addAll(tags);
        }
      }

      if (mounted) {
        setState(() {
          // Only update if there are actual changes to prevent unnecessary rebuilds
          bool hasChanges = false;
          if (_allDocuments.length != updatedDocuments.length) {
            hasChanges = true;
          } else {
            for (int i = 0; i < _allDocuments.length; i++) {
              if (_allDocuments[i].tags != updatedDocuments[i].tags ||
                  _allDocuments[i].title != updatedDocuments[i].title) {
                hasChanges = true;
                break;
              }
            }
          }
          
          if (hasChanges) {
            _allDocuments = updatedDocuments;
            _availableTags = allTags.toList()..sort();
            _applyFilters();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading metadata: $e');
      // Silently fail - documents already shown
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    
    setState(() {
      _filteredDocuments = _allDocuments.where((doc) {
        // Text search filter
        bool matchesText = true;
        if (query.isNotEmpty) {
          final fileName = doc.file.path.split('/').last.toLowerCase();
          final title = (doc.title ?? '').toLowerCase();
          matchesText = fileName.contains(query) || title.contains(query);
        }

        // Tag filter
        bool matchesTags = true;
        if (_selectedTags.isNotEmpty) {
          if (doc.tags == null || doc.tags!.isEmpty) {
            matchesTags = false;
          } else {
            final docTags = doc.tags!
                .split(',')
                .map((t) => t.trim().toLowerCase())
                .where((t) => t.isNotEmpty)
                .toSet();
            matchesTags = _selectedTags.any((selectedTag) => 
                docTags.contains(selectedTag.toLowerCase()));
          }
        }

        return matchesText && matchesTags;
      }).toList();
    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _applyFilters();
    });
  }

  void _clearTagFilters() {
    setState(() {
      _selectedTags.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search documents',
                      hintStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Tag filters section
                if (_availableTags.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'Filter by Tags:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedTags.isNotEmpty)
                        TextButton(
                          onPressed: _clearTagFilters,
                          child: const Text(
                            'Clear',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (_) => _toggleTag(tag),
                        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade400,
                          width: isSelected ? 2 : 1,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Show loading, empty, or results
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_filteredDocuments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchController.text.isEmpty && _selectedTags.isEmpty
                                ? Icons.description
                                : Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty && _selectedTags.isEmpty
                                ? 'No documents yet'
                                : _selectedTags.isNotEmpty && _searchController.text.isNotEmpty
                                    ? 'No results for "${_searchController.text}" with selected tags'
                                    : _selectedTags.isNotEmpty
                                        ? 'No documents match the selected tags'
                                        : 'No results for "${_searchController.text}"',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_selectedTags.isNotEmpty || _searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                _clearTagFilters();
                              },
                              child: const Text('Clear all filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  // Show search results
                  ..._filteredDocuments.map((doc) {
                    final fileName = doc.file.path.split('/').last;
                    final fileDate = doc.file.lastModifiedSync();
                    final displayTitle = doc.title?.isNotEmpty == true 
                        ? doc.title! 
                        : fileName;
                    final docTags = doc.tags != null && doc.tags!.isNotEmpty
                        ? doc.tags!.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
                        : <String>[];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditDocumentPage(filePath: doc.file.path),
                            ),
                          );
                          // Refresh metadata when returning from edit page (files might have changed)
                          if (mounted) {
                            final files = await _imageStorage.getAllDocuments();
                            files.sort((a, b) {
                              return b.lastModifiedSync().compareTo(a.lastModifiedSync());
                            });
                            _loadMetadataInBackground(files);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  doc.file,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.broken_image, size: 30),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // File info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayTitle,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${fileDate.day}/${fileDate.month}/${fileDate.year}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (docTags.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: docTags.take(3).map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Arrow icon
                              Icon(Icons.chevron_right, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
