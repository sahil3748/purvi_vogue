import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/ui/widgets/responsive_wrapper.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class EnhancedCatalogScreen extends StatefulWidget {
  const EnhancedCatalogScreen({super.key});

  @override
  State<EnhancedCatalogScreen> createState() => _EnhancedCatalogScreenState();
}

class _EnhancedCatalogScreenState extends State<EnhancedCatalogScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedCategory = 'All';
  String _selectedSubcategory = 'All';
  String _searchQuery = '';
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  List<CategoryModel> _categories = [];
  List<SubcategoryModel> _subcategories = [];
  bool _isLoading = true;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _startAnimations();
    _loadData();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  void _loadData() async {
    try {
      // Load categories, subcategories, and products simultaneously
      await Future.wait([
        _loadCategories(),
        _loadSubcategories(),
        _loadProducts(),
      ]);
      
      setState(() {
        _isLoading = false;
      });
      
      _filterProducts();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesStream = _firestoreService.watchCategories();
      await for (final categories in categoriesStream) {
        setState(() {
          _categories = categories;
        });
        break; // Take first snapshot
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadSubcategories() async {
    try {
      final subcategoriesStream = _firestoreService.watchSubcategories();
      await for (final subcategories in subcategoriesStream) {
        setState(() {
          _subcategories = subcategories;
        });
        break; // Take first snapshot
      }
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      final productsStream = _firestoreService.watchProducts();
      await for (final products in productsStream) {
        setState(() {
          _allProducts = products;
        });
        break; // Take first snapshot
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        // Category filter
        final matchesCategory = _selectedCategory == 'All' || 
            product.categoryId == _categories.firstWhere((c) => c.name == _selectedCategory, orElse: () => CategoryModel(id: '', name: '')).id;
        
        // Subcategory filter
        final matchesSubcategory = _selectedSubcategory == 'All' || 
            product.subCategoryId == _subcategories.firstWhere((s) => s.name == _selectedSubcategory, orElse: () => SubcategoryModel(id: '', categoryId: '', name: '')).id;
        
        // Search filter
        final matchesSearch = _searchQuery.isEmpty || 
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        
        return matchesCategory && matchesSubcategory && matchesSearch;
      }).toList();
    });
  }

  void _onCategoryChanged(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
      _selectedSubcategory = 'All'; // Reset subcategory when category changes
    });
    _filterProducts();
  }

  void _onSubcategoryChanged(String subcategoryName) {
    setState(() {
      _selectedSubcategory = subcategoryName;
    });
    _filterProducts();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterProducts();
  }

  List<SubcategoryModel> _getSubcategoriesForCategory(String categoryId) {
    if (categoryId == 'All') return [];
    return _subcategories.where((s) => s.categoryId == categoryId).toList();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PurviVogueColors.softBeige,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _buildAppBar(),
          
          // Search and Filter Section
          _buildSearchSection(),
          
          // Categories
          _buildCategoriesSection(),
          
          // Subcategories (if category is selected)
          if (_selectedCategory != 'All') _buildSubcategoriesSection(),
          
          // Products Grid
          _buildProductsSection(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: PurviVogueColors.deepNavy,
      elevation: 0,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PurviVogueColors.deepNavy,
                Color(0xFF2A2A5A),
              ],
            ),
          ),
        ),
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'CATALOG',
            style: TextStyle(
              color: PurviVogueColors.roseGold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
        centerTitle: true,
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: PurviVogueColors.roseGold,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: PurviVogueColors.roseGold,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length + 1, // +1 for "All" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" option
                final isSelected = _selectedCategory == 'All';
                return _buildCategoryChip('All', Icons.all_inclusive, isSelected, () => _onCategoryChanged('All'));
              }
              
              final category = _categories[index - 1];
              final isSelected = _selectedCategory == category.name;
              return _buildCategoryChip(category.name, Icons.category, isSelected, () => _onCategoryChanged(category.name));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoriesSection() {
    final categoryId = _categories.firstWhere((c) => c.name == _selectedCategory, orElse: () => CategoryModel(id: '', name: '')).id;
    final subcategories = _getSubcategoriesForCategory(categoryId);
    
    if (subcategories.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subcategories.length + 1, // +1 for "All" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" option
                final isSelected = _selectedSubcategory == 'All';
                return _buildCategoryChip('All', Icons.all_inclusive, isSelected, () => _onSubcategoryChanged('All'));
              }
              
              final subcategory = subcategories[index - 1];
              final isSelected = _selectedSubcategory == subcategory.name;
              return _buildCategoryChip(subcategory.name, Icons.subdirectory_arrow_right, isSelected, () => _onSubcategoryChanged(subcategory.name));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String name, IconData icon, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? PurviVogueColors.roseGold : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : PurviVogueColors.roseGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : PurviVogueColors.deepNavy,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: PurviVogueColors.roseGold,
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: PurviVogueColors.deepNavy.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  color: PurviVogueColors.deepNavy.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or search terms',
                style: TextStyle(
                  fontSize: 14,
                  color: PurviVogueColors.deepNavy.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context).toInt(),
          childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = _filteredProducts[index];
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildProductCard(product),
              ),
            );
          },
          childCount: _filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to product detail
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrls.isNotEmpty 
                          ? product.imageUrls.first 
                          : 'https://via.placeholder.com/300x400'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: PurviVogueColors.deepNavy,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      if (product.priceRange != null)
                        Text(
                          '\$${product.priceRange!['min']?.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: PurviVogueColors.roseGold,
                          ),
                        ),
                      
                      const Spacer(),
                      
                      // Material info
                      if (product.material != null)
                        Text(
                          product.material!,
                          style: TextStyle(
                            fontSize: 12,
                            color: PurviVogueColors.deepNavy.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
