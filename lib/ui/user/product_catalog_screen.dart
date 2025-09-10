import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/ui/user/widgets/product_card.dart';

class ProductCatalogScreen extends StatefulWidget {
  final String? filter; // 'featured', 'bestseller', 'category', etc.
  final CategoryModel? category;
  final String? searchQuery;

  const ProductCatalogScreen({
    super.key,
    this.filter,
    this.category,
    this.searchQuery,
  });

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedGender = 'All';
  String _sortBy = 'newest';
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          _getScreenTitle(),
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: const Color(0xFF1A237E),
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // Filters
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Gender Filter
                      Row(
                        children: [
                          const Text('Gender: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              children: ['All', 'Women', 'Men', 'Unisex'].map((gender) {
                                return FilterChip(
                                  label: Text(gender),
                                  selected: _selectedGender == gender,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedGender = gender;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sort By
                      Row(
                        children: [
                          const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                                DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                                DropdownMenuItem(value: 'name_asc', child: Text('Name A-Z')),
                                DropdownMenuItem(value: 'name_desc', child: Text('Name Z-A')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _sortBy = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Products Grid
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _getProductStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                List<ProductModel> products = _filterAndSortProducts(snapshot.data!);
                
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<List<ProductModel>> _getProductStream() {
    if (widget.filter == 'featured') {
      return _firestoreService.watchFeaturedProducts();
    } else if (widget.filter == 'bestseller') {
      return _firestoreService.watchBestSellerProducts();
    } else if (widget.category != null) {
      return _firestoreService.watchProductsByCategory(widget.category!.id);
    } else if (_searchController.text.isNotEmpty) {
      return _firestoreService.searchProducts(_searchController.text);
    } else {
      return _firestoreService.watchAvailableProducts();
    }
  }

  List<ProductModel> _filterAndSortProducts(List<ProductModel> products) {
    List<ProductModel> filtered = products;
    
    // Filter by gender
    if (_selectedGender != 'All') {
      filtered = filtered.where((product) {
        return product.gender.contains(_selectedGender);
      }).toList();
    }
    
    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      String query = _searchController.text.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
               (product.description?.toLowerCase().contains(query) ?? false) ||
               product.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }
    
    // Sort products
    switch (_sortBy) {
      case 'newest':
        filtered.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
        break;
      case 'oldest':
        filtered.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
        break;
      case 'name_asc':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    
    return filtered;
  }

  String _getScreenTitle() {
    if (widget.filter == 'featured') return 'Featured Products';
    if (widget.filter == 'bestseller') return 'Best Sellers';
    if (widget.category != null) return widget.category!.name;
    if (widget.searchQuery != null) return 'Search Results';
    return 'All Products';
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
