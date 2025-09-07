import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/ui/widgets/product_card.dart';
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
      appBar: AppBar(
        title: const Text('Purvi Vogue Catalog'),
        backgroundColor: PurviVogueColors.deepNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            padding: ResponsiveUtils.getScreenPadding(context),
            color: PurviVogueColors.white,
            child: StreamBuilder<List<CategoryModel>>(
              stream: _db.watchCategories(),
              builder: (context, categorySnap) {
                final categories = categorySnap.data ?? [];
                if (categories.isEmpty) return const SizedBox.shrink();

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Filter by Category',
                    prefixIcon: const Icon(
                      Icons.filter_list,
                      color: PurviVogueColors.roseGold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
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
                  items = items
                      .where((p) => p.categoryId == _selectedCategoryId)
                      .toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_outlined,
                          size: ResponsiveUtils.isMobile(context) ? 48 : 64,
                          color: PurviVogueColors.blushPink.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.isMobile(context)
                                ? 16
                                : 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for new arrivals',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.isMobile(context)
                                ? 12
                                : 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: ResponsiveUtils.getScreenPadding(context),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(
                      context,
                    ).toInt(),
                    crossAxisSpacing: ResponsiveUtils.isMobile(context)
                        ? 12
                        : 16,
                    mainAxisSpacing: ResponsiveUtils.isMobile(context)
                        ? 12
                        : 16,
                    childAspectRatio: ResponsiveUtils.getCardAspectRatio(
                      context,
                    ),
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final p = items[i];
                    return ProductCard(
                      product: p,
                      onEnquire: () => _enquire(p),
                      firestoreService: _db,
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
