import 'package:flutter/material.dart';
import 'package:purvi_vogue/ui/admin/admin_login_screen.dart';
import 'package:purvi_vogue/ui/admin/admin_setup_screen.dart';
import 'package:purvi_vogue/ui/admin/admin_wrapper.dart';
import 'package:purvi_vogue/ui/admin/categories_screen.dart';
import 'package:purvi_vogue/ui/admin/cloudinary_test_screen.dart';
import 'package:purvi_vogue/ui/admin/dashboard_screen.dart';
import 'package:purvi_vogue/ui/admin/products_list_screen.dart';
import 'package:purvi_vogue/ui/user/catalog_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    '/admin/login': (_) => const AdminLoginScreen(),
    '/admin/setup': (_) => const AdminSetupScreen(),
    '/admin/dashboard': (_) => const AdminWrapper(child: DashboardScreen()),
    '/admin/products': (_) => AdminWrapper(child: ProductsListScreen()),
    '/admin/categories': (_) => const AdminWrapper(child: CategoriesScreen()),
    '/admin/cloudinary-test': (_) => const AdminWrapper(child: CloudinaryTestScreen()),
    '/catalog': (_) => CatalogScreen(),
  };
}


