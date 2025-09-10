import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/banner.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/ui/user/widgets/app_logo_widget.dart';
import 'package:purvi_vogue/ui/user/widgets/search_bar_widget.dart';
import 'package:purvi_vogue/ui/user/widgets/banner_carousel.dart';
import 'package:purvi_vogue/ui/user/widgets/subcategories_horizontal.dart';
import 'package:purvi_vogue/ui/user/widgets/filterable_products_list.dart';
import 'package:purvi_vogue/ui/user/widgets/footer_section.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo on the left side
            const AppLogoWidget(),

            // Search Bar below logo
            SearchBarWidget(
              onSearch: (query) {
                Navigator.pushNamed(
                  context,
                  '/user/search',
                  arguments: {'query': query},
                );
              },
            ),

            // Banner Carousel below search bar
            StreamBuilder<List<BannerModel>>(
              stream: _firestoreService.watchBanners(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return BannerCarousel(banners: snapshot.data!);
                }
                return const SizedBox.shrink();
              },
            ),

            // Horizontal Scrolling Subcategories (smaller view)
            StreamBuilder<List<CategoryModel>>(
              stream: _firestoreService.watchCategories(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return SubcategoriesHorizontal(
                    categories: snapshot.data!,
                    onCategoryTap: (category) {
                      Navigator.pushNamed(
                        context,
                        '/user/category',
                        arguments: category.id,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // Featured Products Section with Options
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/user/products',
                            arguments: {'filter': 'featured'},
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<ProductModel>>(
                    stream: _firestoreService.watchFeaturedProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        return FilterableProductsList(
                          products: snapshot.data!.take(12).toList(),
                          title: 'Featured Products',
                        );
                      }
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // All Products List with Filter Operations
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<List<ProductModel>>(
                stream: _firestoreService.watchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return FilterableProductsList(
                      products: snapshot.data!,
                      title: 'All Products',
                    );
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
