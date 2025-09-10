import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/ui/user/widgets/product_card.dart';

class CategoryProductsScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryProductsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedSubcategoryId;
  String _selectedGender = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          widget.category.name,
          style: const TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A237E)),
      ),
      body: Column(
        children: [
          // Category Description
          if (widget.category.description != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.category.description!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Subcategory Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<List<SubcategoryModel>>(
              stream: _firestoreService.watchSubcategoriesByCategory(widget.category.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Subcategories:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _selectedSubcategoryId == null,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSubcategoryId = null;
                                });
                              },
                            ),
                            ...snapshot.data!.map((subcategory) {
                              return FilterChip(
                                label: Text(subcategory.name),
                                selected: _selectedSubcategoryId == subcategory.id,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedSubcategoryId = selected ? subcategory.id : null;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Gender Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gender:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
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
                  ],
                ),
              ),
            ),
          ),
          
          // Products Grid
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _selectedSubcategoryId != null
                  ? _firestoreService.watchProductsBySubcategory(_selectedSubcategoryId!)
                  : _firestoreService.watchProductsByCategory(widget.category.id),
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
                          'No products found in this category',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                List<ProductModel> products = _filterProducts(snapshot.data!);
                
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

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    if (_selectedGender == 'All') {
      return products;
    }
    
    return products.where((product) {
      return product.gender.contains(_selectedGender);
    }).toList();
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
