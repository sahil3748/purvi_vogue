import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEnquire;
  final FirestoreService firestoreService;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEnquire,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Stack(
              children: [
                _buildProductImage(),
                if (product.isFeatured) _buildFeaturedBadge(context),
              ],
            ),
          ),

          // Product Details
          Padding(
            padding: EdgeInsets.all(
              ResponsiveUtils.isMobile(context) ? 10.0 : 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),

                // Category Badge
                _buildCategoryBadge(context),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),

                // Enquire Button
                _buildEnquireButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.imageUrls.isNotEmpty) {
      return Image.network(
        product.imageUrls.first,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Builder(
      builder: (context) => Container(
        color: PurviVogueColors.blushPink.withOpacity(0.2),
        child: Icon(
          Icons.image_outlined,
          color: PurviVogueColors.blushPink.withOpacity(0.6),
          size: ResponsiveUtils.isMobile(context) ? 32 : 48,
        ),
      ),
    );
  }

  Widget _buildFeaturedBadge(BuildContext context) {
    return Positioned(
      top: ResponsiveUtils.isMobile(context) ? 6 : 8,
      right: ResponsiveUtils.isMobile(context) ? 6 : 8,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.isMobile(context) ? 6 : 8,
          vertical: ResponsiveUtils.isMobile(context) ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: PurviVogueColors.roseGold,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: ResponsiveUtils.isMobile(context) ? 12 : 14,
              color: PurviVogueColors.white,
            ),
            SizedBox(width: ResponsiveUtils.isMobile(context) ? 3 : 4),
            Text(
              'Featured',
              style: TextStyle(
                fontSize: ResponsiveUtils.isMobile(context) ? 8 : 10,
                color: PurviVogueColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: firestoreService.watchCategories(),
      builder: (context, categorySnap) {
        final categories = categorySnap.data ?? [];
        final category = categories.firstWhere(
          (c) => c.id == product.categoryId,
          orElse: () => CategoryModel(id: '', name: ''),
        );

        if (category.name.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.isMobile(context) ? 4 : 6,
            vertical: ResponsiveUtils.isMobile(context) ? 1 : 2,
          ),
          decoration: BoxDecoration(
            color: PurviVogueColors.blushPink.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            category.name,
            style: TextStyle(
              fontSize: ResponsiveUtils.isMobile(context) ? 8 : 10,
              color: PurviVogueColors.roseGold,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnquireButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onEnquire,
        icon: Icon(
          Icons.message,
          size: ResponsiveUtils.isMobile(context) ? 14 : 16,
        ),
        label: Text(
          'Enquire',
          style: TextStyle(
            fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: PurviVogueColors.roseGold,
          foregroundColor: PurviVogueColors.white,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.isMobile(context) ? 6 : 8,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
