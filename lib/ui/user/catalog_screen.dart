import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _db = FirestoreService();
  String? _selectedCategoryId;

  Future<void> _enquire(ProductModel p) async {
    final msg = Uri.encodeComponent(
      "Hi, I'm interested in the product: ${p.name} (ID: ${p.id}). Can you share pricing?",
    );
    final uri = Uri.parse('https://wa.me/?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Purvi Vogue Catalog'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: StreamBuilder<List<CategoryModel>>(
              stream: _db.watchCategories(),
              builder: (context, categorySnap) {
                final categories = categorySnap.data ?? [];
                if (categories.isEmpty) return const SizedBox.shrink();
                
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Filter by Category',
                    prefixIcon: const Icon(Icons.filter_list),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                );
              },
            ),
          ),
          
          // Products Grid
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _db.watchProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var items = snap.data ?? [];
                
                // Filter by category if selected
                if (_selectedCategoryId != null) {
                  items = items.where((p) => p.categoryId == _selectedCategoryId).toList();
                }
                
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for new arrivals',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                (p.imageUrls.isNotEmpty)
                                    ? Image.network(
                                        p.imageUrls.first,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
                                      ),
                                if (p.isFeatured)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star, size: 14, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Featured',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StreamBuilder<List<CategoryModel>>(
                                  stream: _db.watchCategories(),
                                  builder: (context, categorySnap) {
                                    final categories = categorySnap.data ?? [];
                                    final category = categories.firstWhere(
                                      (c) => c.id == p.categoryId,
                                      orElse: () => CategoryModel(id: '', name: ''),
                                    );
                                    if (category.name.isEmpty) return const SizedBox.shrink();
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _enquire(p),
                                    icon: const Icon(Icons.message, size: 16),
                                    label: const Text('Enquire'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


