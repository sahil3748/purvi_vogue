import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/models/product.dart';
import 'package:purvi_vogue/models/category.dart';
import 'package:purvi_vogue/models/subcategory.dart';
import 'package:purvi_vogue/ui/admin/comprehensive_product_form.dart';
import 'package:purvi_vogue/ui/admin/enhanced_category_form.dart';
import 'package:purvi_vogue/ui/admin/enhanced_subcategory_form.dart';
import 'package:purvi_vogue/ui/admin/enhanced_subcategories_screen.dart';
import 'package:purvi_vogue/ui/admin/products_list_screen.dart';
import 'package:purvi_vogue/ui/admin/categories_screen.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedIndex = 0;
  bool _isLoading = true;

  // Statistics
  int _totalProducts = 0;
  int _totalCategories = 0;
  int _totalSubcategories = 0;
  int _featuredProducts = 0;
  int _outOfStockProducts = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      // Load products count
      final productsStream = _firestoreService.watchProducts();
      await for (final products in productsStream) {
        _totalProducts = products.length;
        _featuredProducts = products.where((p) => p.isFeatured).length;
        _outOfStockProducts = products.where((p) => !p.inStock).length;
        break;
      }

      // Load categories count
      final categoriesStream = _firestoreService.watchCategories();
      await for (final categories in categoriesStream) {
        _totalCategories = categories.length;
        break;
      }

      // Load subcategories count
      final subcategoriesStream = _firestoreService.watchSubcategories();
      await for (final subcategories in subcategoriesStream) {
        _totalSubcategories = subcategories.length;
        break;
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 800,
            minExtendedWidth: 200,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            selectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            unselectedLabelTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category),
                label: Text('Categories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.subdirectory_arrow_right),
                label: Text('Subcategories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),

          // Main Content
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return ProductsListScreen();
      case 2:
        return const CategoriesScreen();
      case 3:
        return const EnhancedSubcategoriesScreen();
      case 4:
        return _buildAnalyticsScreen();
      case 5:
        return _buildSettingsScreen();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStatistics,
            ),
            const SizedBox(width: 16),
          ],
        ),

        // Statistics Cards
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildStatCard(index),
              childCount: 5,
            ),
          ),
        ),

        // Quick Actions
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickActions(),
              ],
            ),
          ),
        ),

        // Recent Activity
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentActivity(),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildStatCard(int index) {
    if (_isLoading) {
      return Card(
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final stats = [
      {
        'title': 'Total Products',
        'value': _totalProducts.toString(),
        'icon': Icons.inventory,
        'color': Colors.blue,
        'subtitle': 'Items in catalog',
      },
      {
        'title': 'Categories',
        'value': _totalCategories.toString(),
        'icon': Icons.category,
        'color': Colors.green,
        'subtitle': 'Product categories',
      },
      {
        'title': 'Subcategories',
        'value': _totalSubcategories.toString(),
        'icon': Icons.subdirectory_arrow_right,
        'color': Colors.orange,
        'subtitle': 'Product subcategories',
      },
      {
        'title': 'Featured',
        'value': _featuredProducts.toString(),
        'icon': Icons.star,
        'color': Colors.amber,
        'subtitle': 'Featured products',
      },
      {
        'title': 'Out of Stock',
        'value': _outOfStockProducts.toString(),
        'icon': Icons.warning,
        'color': Colors.red,
        'subtitle': 'Needs restocking',
      },
    ];

    final stat = stats[index];
    final color = stat['color'] as Color;
    final icon = stat['icon'] as IconData;
    final value = stat['value'] as String;
    final title = stat['title'] as String;
    final subtitle = stat['subtitle'] as String;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildQuickActionCard(
          'Add Product',
          Icons.add_shopping_cart,
          Colors.blue,
          () => _navigateToProductForm(),
        ),
        _buildQuickActionCard(
          'Add Category',
          Icons.category,
          Colors.green,
          () => _navigateToCategoryForm(),
        ),
        _buildQuickActionCard(
          'Add Subcategory',
          Icons.subdirectory_arrow_right,
          Colors.orange,
          () => _navigateToSubcategoryForm(),
        ),
        _buildQuickActionCard(
          'View Analytics',
          Icons.analytics,
          Colors.purple,
          () => setState(() => _selectedIndex = 4),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(Icons.add_shopping_cart, color: Colors.blue),
              ),
              title: Text('New product added'),
              subtitle: Text('Elegant Necklace Collection'),
              trailing: Text('2 hours ago'),
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Icon(Icons.category, color: Colors.green),
              ),
              title: Text('Category updated'),
              subtitle: Text('Jewelry category modified'),
              trailing: Text('5 hours ago'),
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: Icon(Icons.star, color: Colors.orange),
              ),
              title: Text('Product featured'),
              subtitle: Text('Rose Gold Ring featured'),
              trailing: Text('1 day ago'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsScreen() {
    return const Center(child: Text('Analytics Dashboard - Coming Soon'));
  }

  Widget _buildSettingsScreen() {
    return const Center(child: Text('Settings - Coming Soon'));
  }

  void _navigateToProductForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ComprehensiveProductForm()),
    );
  }

  void _navigateToCategoryForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EnhancedCategoryForm()),
    );
  }

  void _navigateToSubcategoryForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EnhancedSubcategoryForm()),
    );
  }
}
