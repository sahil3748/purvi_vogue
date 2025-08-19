import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/ui/widgets/responsive_wrapper.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';

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
  String _searchQuery = '';
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _categories = [
    {'id': '1', 'name': 'All', 'icon': Icons.all_inclusive},
    {'id': '2', 'name': 'Necklaces', 'icon': Icons.diamond},
    {'id': '3', 'name': 'Kurtis', 'icon': Icons.style},
    {'id': '4', 'name': 'Earrings', 'icon': Icons.auto_awesome},
    {'id': '5', 'name': 'Bracelets', 'icon': Icons.circle},
    {'id': '6', 'name': 'Rings', 'icon': Icons.favorite},
  ];

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
    _loadProducts();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
  }

  void _loadProducts() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock products data
    final products = [
      ProductModel(
        id: '1',
        name: 'Royal Gold Necklace',
        description: 'Elegant gold necklace with intricate design',
        priceRange: {'min': 299.99, 'max': 299.99},
        categoryId: '2',
        subCategoryId: 'necklaces',
        gender: ['Women'],
        imageUrls: ['https://via.placeholder.com/300x400/FFD700/000000?text=Necklace'],
        tags: ['gold', 'necklace', 'elegant'],
        material: '18K Gold',
        inStock: true,
      ),
      ProductModel(
        id: '2',
        name: 'Silk Embroidered Kurti',
        description: 'Beautiful silk kurti with hand embroidery',
        priceRange: {'min': 89.99, 'max': 89.99},
        categoryId: '3',
        subCategoryId: 'kurtis',
        gender: ['Women'],
        imageUrls: ['https://via.placeholder.com/300x400/FF69B4/000000?text=Kurti'],
        tags: ['silk', 'kurti', 'embroidery'],
        material: 'Pure Silk',
        inStock: true,
      ),
      ProductModel(
        id: '3',
        name: 'Pearl Drop Earrings',
        description: 'Classic pearl drop earrings',
        priceRange: {'min': 45.99, 'max': 45.99},
        categoryId: '4',
        subCategoryId: 'earrings',
        gender: ['Women'],
        imageUrls: ['https://via.placeholder.com/300x400/87CEEB/000000?text=Earrings'],
        tags: ['pearl', 'earrings', 'classic'],
        material: 'Freshwater Pearl',
        inStock: true,
      ),
      ProductModel(
        id: '4',
        name: 'Diamond Stud Earrings',
        description: 'Sparkling diamond studs',
        priceRange: {'min': 199.99, 'max': 199.99},
        categoryId: '4',
        subCategoryId: 'earrings',
        gender: ['Women'],
        imageUrls: ['https://via.placeholder.com/300x400/C0C0C0/000000?text=Diamond'],
        tags: ['diamond', 'earrings', 'sparkling'],
        material: '14K White Gold',
        inStock: true,
      ),
      ProductModel(
        id: '5',
        name: 'Silver Chain Bracelet',
        description: 'Delicate silver chain bracelet',
        priceRange: {'min': 35.99, 'max': 35.99},
        categoryId: '5',
        subCategoryId: 'bracelets',
        gender: ['Women'],
        imageUrls: ['https://via.placeholder.com/300x400/808080/000000?text=Bracelet'],
        tags: ['silver', 'bracelet', 'delicate'],
        material: '925 Sterling Silver',
        inStock: true,
      ),
      ProductModel(
        id: '6',
        name: 'Rose Gold Ring',
        description: 'Elegant rose gold ring',
        priceRange: {'min': 79.99, 'max': 79.99},
        categoryId: '6',
        subCategoryId: 'rings',
        gender: ['Women'],
        imageUrls: ['https://via.placeholder.com/300x400/FFB6C1/000000?text=Ring'],
        tags: ['rose gold', 'ring', 'elegant'],
        material: '14K Rose Gold',
        inStock: true,
      ),
    ];

    setState(() {
      _filteredProducts = products;
      _isLoading = false;
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _filteredProducts.where((product) {
        final matchesCategory = _selectedCategory == 'All' || 
            product.categoryId == _categories.firstWhere((c) => c['name'] == _selectedCategory)['id'];
        final matchesSearch = _searchQuery.isEmpty || 
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        return matchesCategory && matchesSearch;
      }).toList();
    });
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
                onChanged: (value) {
                  _searchQuery = value;
                  _filterProducts();
                },
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
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category['name'];
              
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                    _filterProducts();
                  },
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
                          category['icon'] as IconData,
                          color: isSelected ? Colors.white : PurviVogueColors.roseGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'],
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
            },
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
