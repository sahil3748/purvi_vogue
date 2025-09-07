import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/ui/admin/enhanced_subcategory_form.dart';

class EnhancedSubcategoriesScreen extends StatefulWidget {
  const EnhancedSubcategoriesScreen({super.key});

  @override
  State<EnhancedSubcategoriesScreen> createState() =>
      _EnhancedSubcategoriesScreenState();
}

class _EnhancedSubcategoriesScreenState
    extends State<EnhancedSubcategoriesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load categories
      final categoriesStream = _firestoreService.watchCategories();
      await for (final categories in categoriesStream) {
        setState(() {
          _categories = categories;
          if (categories.isNotEmpty) {
            _selectedCategory = categories.first;
            _loadSubcategories();
          }
        });
        break;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubcategories() async {
    if (_selectedCategory == null) return;

    try {
      final subcategoriesStream = _firestoreService
          .watchSubcategoriesByCategory(_selectedCategory!.id);
      await for (final subcategories in subcategoriesStream) {
        setState(() {
          _subcategories = subcategories;
        });
        break;
      }
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  List<SubcategoryModel> get _filteredSubcategories {
    if (_searchQuery.isEmpty) return _subcategories;
    return _subcategories
        .where(
          (sub) =>
              sub.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (sub.description?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  Future<void> _deleteSubcategory(SubcategoryModel subcategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text(
          'Are you sure you want to delete "${subcategory.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteSubcategory(subcategory.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subcategory deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting subcategory: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.subdirectory_arrow_right,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subcategories Management',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        'Organize your products with subcategories',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _navigateToSubcategoryForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subcategory'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 2,
                  ),
                ),
              ],
            ),
          ),

          // Filters and Search
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Category Filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<CategoryModel>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Filter by Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (CategoryModel? value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      if (value != null) {
                        _loadSubcategories();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Search
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Subcategories',
                      hintText: 'Search by name or description...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubcategories.isEmpty
                ? _buildEmptyState()
                : _buildSubcategoriesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subdirectory_arrow_right,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No subcategories found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Create your first subcategory to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToSubcategoryForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add Subcategory'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _filteredSubcategories.length,
      itemBuilder: (context, index) {
        final subcategory = _filteredSubcategories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.subdirectory_arrow_right,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            title: Text(
              subcategory.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subcategory.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subcategory.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Category: ${_getCategoryName(subcategory.categoryId)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _navigateToSubcategoryForm(subcategory: subcategory);
                    break;
                  case 'delete':
                    _deleteSubcategory(subcategory);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel(id: '', name: 'Unknown'),
    );
    return category.name;
  }

  void _navigateToSubcategoryForm({SubcategoryModel? subcategory}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EnhancedSubcategoryForm(
              subcategory: subcategory,
              isEditing: subcategory != null,
            ),
          ),
        )
        .then((_) {
          _loadSubcategories();
        });
  }
}
