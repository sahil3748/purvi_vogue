import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/category.dart';

class SubcategoriesHorizontal extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategoryTap;

  const SubcategoriesHorizontal({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Shop by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      if (onCategoryTap != null) {
                        onCategoryTap!(category);
                      } else {
                        Navigator.pushNamed(
                          context,
                          '/user/category',
                          arguments: category.id,
                        );
                      }
                    },
                    child: Column(
                      children: [
                        // Category Image/Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFF1A237E).withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: category.thumbnailUrl != null && category.thumbnailUrl!.isNotEmpty
                                ? Image.network(
                                    category.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultIcon(category.name);
                                    },
                                  )
                                : _buildDefaultIcon(category.name),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Category Name
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon(String categoryName) {
    IconData iconData;
    Color iconColor = const Color(0xFF1A237E);

    // Assign icons based on category name
    switch (categoryName.toLowerCase()) {
      case 'women':
      case 'woman':
        iconData = Icons.woman;
        break;
      case 'men':
      case 'man':
        iconData = Icons.man;
        break;
      case 'kids':
      case 'children':
        iconData = Icons.child_care;
        break;
      case 'shoes':
      case 'footwear':
        iconData = Icons.sports_tennis;
        break;
      case 'accessories':
        iconData = Icons.watch;
        break;
      case 'bags':
      case 'handbags':
        iconData = Icons.shopping_bag;
        break;
      case 'jewelry':
      case 'jewellery':
        iconData = Icons.diamond;
        break;
      default:
        iconData = Icons.category;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 28,
    );
  }
}
