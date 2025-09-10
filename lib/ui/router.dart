import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/ui/admin/auth_wrapper.dart';
import 'package:purvi_vogue/ui/admin/admin_login_screen.dart';
import 'package:purvi_vogue/ui/admin/admin_setup_screen.dart';
import 'package:purvi_vogue/ui/admin/admin_dashboard.dart';
import 'package:purvi_vogue/ui/admin/simple_categories_screen.dart';
import 'package:purvi_vogue/ui/admin/simple_subcategories_screen.dart';
import 'package:purvi_vogue/ui/admin/simple_product_types_screen.dart';
import 'package:purvi_vogue/ui/admin/simple_products_screen.dart';
import 'package:purvi_vogue/ui/admin/products_list_screen.dart';
import 'package:purvi_vogue/ui/admin/product_management_screen.dart';
import 'package:purvi_vogue/ui/admin/category_options_screen.dart';
import 'package:purvi_vogue/ui/admin/categories_list_screen.dart';
import 'package:purvi_vogue/ui/admin/subcategories_list_screen.dart';
import 'package:purvi_vogue/ui/admin/product_types_list_screen.dart';
import 'package:purvi_vogue/ui/user/user_home_screen.dart';
import 'package:purvi_vogue/ui/user/product_catalog_screen.dart';
import 'package:purvi_vogue/ui/user/product_detail_screen.dart';
import 'package:purvi_vogue/ui/user/category_products_screen.dart';
import 'package:purvi_vogue/ui/user/search_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    // Platform detection route
    '/': (context) => _getPlatformRoute(context),
    
    // User routes (Web-focused)
    '/user/home': (_) => const UserHomeScreen(),
    '/user/products': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return ProductCatalogScreen(
        filter: args?['filter'],
        category: args?['category'],
        searchQuery: args?['searchQuery'],
      );
    },
    '/user/product-detail': (context) {
      final product = ModalRoute.of(context)!.settings.arguments as ProductModel;
      return ProductDetailScreen(product: product);
    },
    '/user/category-products': (context) {
      final category = ModalRoute.of(context)!.settings.arguments as CategoryModel;
      return CategoryProductsScreen(category: category);
    },
    '/user/search': (context) {
      final searchQuery = ModalRoute.of(context)?.settings.arguments as String?;
      return SearchScreen(initialQuery: searchQuery);
    },
    
    // Admin routes (Mobile-focused)
    '/admin': (_) => const AuthWrapper(), // Admin entry point
    '/admin/login': (_) => const AdminLoginScreen(),
    '/admin/setup': (_) => const AdminSetupScreen(),
    '/admin/dashboard': (_) => const AdminDashboard(),
    '/admin/categories': (_) => const SimpleCategoriesScreen(),
    '/admin/categories-list': (_) => const CategoriesListScreen(),
    '/admin/subcategories': (_) => const SimpleSubcategoriesScreen(),
    '/admin/subcategories-list': (_) => const SubcategoriesListScreen(),
    '/admin/product-types': (_) => const SimpleProductTypesScreen(),
    '/admin/product-types-list': (_) => const ProductTypesListScreen(),
    '/admin/products': (_) => const SimpleProductsScreen(),
    '/admin/products-list': (_) => const ProductsListScreen(),
    '/admin/product-management': (_) => const ProductManagementScreen(),
    '/admin/category-options': (context) {
      final category = ModalRoute.of(context)!.settings.arguments as CategoryModel;
      return CategoryOptionsScreen(category: category);
    },
  };

  // Platform detection logic
  static Widget _getPlatformRoute(BuildContext context) {
    if (kIsWeb) {
      // Web users go to user interface
      return const UserHomeScreen();
    } else {
      // Mobile users go to admin interface
      return const AuthWrapper();
    }
  }
}
