import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/ui/admin/simple_categories_screen.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<CategoryModel> _categories = [];
  List<CategoryModel> _filteredCategories = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadCategories();
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _categories.where((category) {
        return category.name.toLowerCase().contains(query) ||
            (category.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _firestoreService.getCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
      });
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCategory(String categoryId) async {
    final category = _categories.firstWhere(
      (element) => element.id == categoryId,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: PurviVogueColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await _firestoreService.deleteCategory(category.id);
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting category: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _editCategory(CategoryModel category) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const SimpleCategoriesScreen(),
          ),
        )
        .then((_) {
          // Refresh the list when returning from edit screen
          _loadCategories();
        });
  }

  void _addNewCategory() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const SimpleCategoriesScreen(),
          ),
        )
        .then((_) {
          // Refresh the list when returning from add screen
          _loadCategories();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_filteredCategories.length} categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: PurviVogueColors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          // IconButton(
          //   onPressed: _addNewCategory,
          //   icon: const Icon(Icons.add_circle_outline),
          //   tooltip: 'Add New Category',
          // ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            decoration: BoxDecoration(
              color: PurviVogueColors.deepNavy,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(
                    Icons.search,
                    color: PurviVogueColors.deepNavy,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: _isLoading && _categories.isEmpty
                ? _buildLoadingState()
                : _filteredCategories.isEmpty
                ? _buildEmptyState()
                : _buildCategoriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCategory,
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        elevation: 8,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              PurviVogueColors.deepNavy,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading categories...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: PurviVogueColors.roseGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? Icons.search_off : Icons.category_outlined,
                size: 60,
                color: PurviVogueColors.deepNavy.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'No matching categories' : 'No categories yet',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: PurviVogueColors.charcoal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'Try adjusting your search terms'
                  : 'Create your first category to organize your products',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _addNewCategory,
                icon: const Icon(Icons.add),
                label: const Text('Create Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PurviVogueColors.deepNavy,
                  foregroundColor: PurviVogueColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: PurviVogueColors.deepNavy,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _filteredCategories.length,
            itemBuilder: (context, index) {
              final category = _filteredCategories[index];
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          index * 0.1,
                          1.0,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                  ),
                  child: _buildCategoryCard(category, index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _editCategory(category),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Category Image/Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        PurviVogueColors.roseGold.withOpacity(0.8),
                        PurviVogueColors.warmGold.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: category.thumbnailUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            category.thumbnailUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    PurviVogueColors.deepNavy,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCategoryInitial(category.name);
                            },
                          ),
                        )
                      : _buildCategoryInitial(category.name),
                ),

                const SizedBox(width: 16),

                // Category Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: PurviVogueColors.charcoal,
                        ),
                      ),
                      if (category.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          category.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: PurviVogueColors.deepNavy.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Created ${category.createdAt != null ? _formatDate(category.createdAt!) : 'Unknown'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: PurviVogueColors.deepNavy,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Column(
                  children: [
                    _buildActionButton(
                      icon: Icons.settings_outlined,
                      color: PurviVogueColors.warmGold,
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/admin/category-options',
                          arguments: category,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      color: PurviVogueColors.deepNavy,
                      onPressed: () => _editCategory(category),
                    ),
                    const SizedBox(height: 8),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: PurviVogueColors.error,
                      onPressed: () => _deleteCategory(category.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        color: color,
        padding: EdgeInsets.zero,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
