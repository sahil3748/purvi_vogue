import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/ui/admin/simple_subcategories_screen.dart';
import 'package:purvi_vogue/ui/admin/product_types_list_screen.dart';

class SubcategoriesListScreen extends StatefulWidget {
  const SubcategoriesListScreen({super.key});

  @override
  State<SubcategoriesListScreen> createState() =>
      _SubcategoriesListScreenState();
}

class _SubcategoriesListScreenState extends State<SubcategoriesListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<SubcategoryModel> _subcategories = [];
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategoryFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _firestoreService.getCategories();
      final subcategories = await _firestoreService.getSubcategories();
      setState(() {
        _categories = categories;
        _subcategories = subcategories;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSubcategory(SubcategoryModel subcategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text('Are you sure you want to delete "${subcategory.name}"?'),
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
        await _firestoreService.deleteSubcategory(subcategory.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subcategory deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting subcategory: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _editSubcategory(SubcategoryModel subcategory) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const SimpleSubcategoriesScreen(),
          ),
        )
        .then((_) {
          _loadData();
        });
  }

  void _addNewSubcategory() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const SimpleSubcategoriesScreen(),
          ),
        )
        .then((_) {
          _loadData();
        });
  }

  List<SubcategoryModel> get _filteredSubcategories {
    var filtered = _subcategories;
    
    // Filter by category
    if (_selectedCategoryFilter != null) {
      filtered = filtered
          .where((sub) => sub.categoryId == _selectedCategoryFilter!.id)
          .toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((sub) => 
              sub.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (sub.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }
    
    return filtered;
  }

  String _getCategoryName(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel(id: '', name: 'Unknown Category'),
    );
    return category.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Subcategories'),
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProductTypesListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.label),
            tooltip: 'View Product Types',
          ),
          // IconButton(
          //   onPressed: _addNewSubcategory,
          //   icon: const Icon(Icons.add),
          //   tooltip: 'Add New Subcategory',
          // ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [PurviVogueColors.white, PurviVogueColors.softCream],
          ),
        ),
        child: Column(
          children: [
            // Header with Statistics
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [PurviVogueColors.deepNavy, PurviVogueColors.deepNavy.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: PurviVogueColors.deepNavy.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subcategories Management',
                          style: const TextStyle(
                            color: PurviVogueColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_filteredSubcategories.length} of ${_subcategories.length} subcategories',
                          style: TextStyle(
                            color: PurviVogueColors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PurviVogueColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.category,
                      color: PurviVogueColors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: PurviVogueColors.white,
                borderRadius: BorderRadius.circular(12),
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search subcategories...',
                  prefixIcon: const Icon(Icons.search, color: PurviVogueColors.deepNavy),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: PurviVogueColors.deepNavy),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: PurviVogueColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Filter
            if (_categories.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PurviVogueColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PurviVogueColors.roseGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: PurviVogueColors.deepNavy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<CategoryModel?>(
                        value: _selectedCategoryFilter,
                        decoration: InputDecoration(
                          labelText: 'Filter by Category',
                          labelStyle: const TextStyle(color: PurviVogueColors.deepNavy),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: PurviVogueColors.deepNavy.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: PurviVogueColors.deepNavy.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: PurviVogueColors.deepNavy),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<CategoryModel?>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ..._categories.map(
                            (category) => DropdownMenuItem<CategoryModel?>(
                              value: category,
                              child: Text(category.name),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryFilter = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Subcategories List
            Expanded(
              child: _isLoading && _subcategories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSubcategories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategoryFilter != null
                                ? 'No subcategories in this category'
                                : 'No subcategories found',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: PurviVogueColors.charcoal,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first subcategory to get started',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _addNewSubcategory,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Subcategory'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PurviVogueColors.deepNavy,
                              foregroundColor: PurviVogueColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredSubcategories.length,
                        itemBuilder: (context, index) {
                          final subcategory = _filteredSubcategories[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: PurviVogueColors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Image/Avatar
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            colors: [
                                              PurviVogueColors.roseGold,
                                              PurviVogueColors.roseGold.withOpacity(0.8),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: PurviVogueColors.roseGold.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: subcategory.thumbnailUrl != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  subcategory.thumbnailUrl!,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return const Center(
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor: AlwaysStoppedAnimation<Color>(
                                                          PurviVogueColors.deepNavy,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Center(
                                                      child: Text(
                                                        subcategory.name.substring(0, 1).toUpperCase(),
                                                        style: const TextStyle(
                                                          color: PurviVogueColors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 24,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  subcategory.name.substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    color: PurviVogueColors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Content
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              subcategory.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: PurviVogueColors.charcoal,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    PurviVogueColors.deepNavy.withOpacity(0.1),
                                                    PurviVogueColors.deepNavy.withOpacity(0.05),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: PurviVogueColors.deepNavy.withOpacity(0.2),
                                                ),
                                              ),
                                              child: Text(
                                                _getCategoryName(subcategory.categoryId),
                                                style: const TextStyle(
                                                  color: PurviVogueColors.deepNavy,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  if (subcategory.description != null) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: PurviVogueColors.softCream.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        subcategory.description!,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                PurviVogueColors.roseGold.withOpacity(0.8),
                                                PurviVogueColors.roseGold,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => const ProductTypesListScreen(),
                                                  ),
                                                );
                                              },
                                              child: const Center(
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.label_outline,
                                                      color: PurviVogueColors.white,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Product Types',
                                                      style: TextStyle(
                                                        color: PurviVogueColors.white,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: PurviVogueColors.deepNavy.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(8),
                                            onTap: () => _editSubcategory(subcategory),
                                            child: const Icon(
                                              Icons.edit,
                                              color: PurviVogueColors.deepNavy,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: PurviVogueColors.error.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(8),
                                            onTap: () => _deleteSubcategory(subcategory),
                                            child: const Icon(
                                              Icons.delete,
                                              color: PurviVogueColors.error,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [PurviVogueColors.deepNavy, PurviVogueColors.deepNavy.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: PurviVogueColors.deepNavy.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addNewSubcategory,
          backgroundColor: Colors.transparent,
          foregroundColor: PurviVogueColors.white,
          elevation: 0,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
