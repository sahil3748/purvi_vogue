import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/ui/user/widgets/product_card.dart';

class FilterableProductsList extends StatefulWidget {
  final List<ProductModel> products;
  final String title;

  const FilterableProductsList({
    super.key,
    required this.products,
    this.title = 'All Products',
  });

  @override
  State<FilterableProductsList> createState() => _FilterableProductsListState();
}

class _FilterableProductsListState extends State<FilterableProductsList> {
  List<ProductModel> _filteredProducts = [];
  String _selectedGender = 'All';
  String _selectedSort = 'Name A-Z';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
  }

  @override
  void didUpdateWidget(FilterableProductsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _filteredProducts = widget.products;
      _applyFilters();
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = widget.products.where((product) {
        // Gender filter
        bool genderMatch = _selectedGender == 'All' || 
            product.gender.any((g) => g.toLowerCase() == _selectedGender.toLowerCase());
        
        return genderMatch;
      }).toList();

      // Apply sorting
      switch (_selectedSort) {
        case 'Name A-Z':
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Name Z-A':
          _filteredProducts.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'Price Low-High':
          _filteredProducts.sort((a, b) => _getMinPrice(a).compareTo(_getMinPrice(b)));
          break;
        case 'Price High-Low':
          _filteredProducts.sort((a, b) => _getMaxPrice(b).compareTo(_getMaxPrice(a)));
          break;
        case 'Newest':
          _filteredProducts.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
          break;
      }
    });
  }

  double _getMinPrice(ProductModel product) {
    return product.priceRange?['min']?.toDouble() ?? 0.0;
  }

  double _getMaxPrice(ProductModel product) {
    return product.priceRange?['max']?.toDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and filter toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_filteredProducts.length} items',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ],
          ),
          
          // Filter Options
          if (_showFilters) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // Gender Filter
                  Row(
                    children: [
                      Text(
                        'Gender: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: ['All', 'Men', 'Women', 'Unisex'].map((gender) {
                            return FilterChip(
                              label: Text(gender),
                              selected: _selectedGender == gender,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedGender = gender;
                                });
                                _applyFilters();
                              },
                              selectedColor: const Color(0xFF1A237E).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF1A237E),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Sort Options
                  Row(
                    children: [
                      Text(
                        'Sort by: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedSort,
                          isExpanded: true,
                          underline: Container(),
                          items: [
                            'Name A-Z',
                            'Name Z-A',
                            'Price Low-High',
                            'Price High-Low',
                            'Newest',
                          ].map((sort) {
                            return DropdownMenuItem(
                              value: sort,
                              child: Text(sort),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSort = value;
                              });
                              _applyFilters();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Products Grid
          if (_filteredProducts.isEmpty)
            Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = _getProductCrossAxisCount(constraints.maxWidth);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: _filteredProducts[index]);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  int _getProductCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
