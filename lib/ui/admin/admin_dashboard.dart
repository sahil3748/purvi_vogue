import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
import 'package:purvi_vogue/services/auth_service.dart';
import 'package:purvi_vogue/services/firestore_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FirestoreService _firestoreService = FirestoreService();
  
  // Real data counts
  int _categoriesCount = 0;
  int _subcategoriesCount = 0;
  int _productTypesCount = 0;
  int _productsCount = 0;
  int _inStockCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        _firestoreService.getCategoriesCount(),
        _firestoreService.getSubcategoriesCount(),
        _firestoreService.getProductTypesCount(),
        _firestoreService.getProductsCount(),
        _firestoreService.getInStockProductsCount(),
      ]);

      if (mounted) {
        setState(() {
          _categoriesCount = results[0];
          _subcategoriesCount = results[1];
          _productTypesCount = results[2];
          _productsCount = results[3];
          _inStockCount = results[4];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600 && screenSize.width < 1024;
    final isMobile = screenSize.width < 600;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PurviVogueColors.deepNavy.withOpacity(0.05),
              PurviVogueColors.roseGold.withOpacity(0.03),
              PurviVogueColors.softCream,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Modern Header Section
                SliverToBoxAdapter(
                  child: _buildModernHeader(context),
                ),
                
                // Stats Overview Section
                SliverToBoxAdapter(
                  child: _buildResponsiveStatsSection(context, isMobile, isTablet),
                ),
                
                // Management Center Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(screenSize.width),
                      vertical: 24,
                    ),
                    child: Text(
                      'Management Center',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: PurviVogueColors.deepNavy,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                // Dashboard Cards Grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(screenSize.width),
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(screenSize.width),
                      crossAxisSpacing: _getGridSpacing(screenSize.width),
                      mainAxisSpacing: _getGridSpacing(screenSize.width),
                      childAspectRatio: _getChildAspectRatio(screenSize.width),
                    ),
                    delegate: SliverChildListDelegate([
                      _buildModernDashboardCard(
                        context,
                        'Categories',
                        'Manage product categories',
                        Icons.dashboard_customize_rounded,
                        const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        _isLoading ? '...' : '$_categoriesCount',
                        () => Navigator.of(context).pushNamed('/admin/categories-list'),
                      ),
                      _buildModernDashboardCard(
                        context,
                        'Subcategories',
                        'Organize subcategories',
                        Icons.account_tree_rounded,
                        const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        ),
                        _isLoading ? '...' : '$_subcategoriesCount',
                        () => Navigator.of(context).pushNamed('/admin/subcategories-list'),
                      ),
                      _buildModernDashboardCard(
                        context,
                        'Product Types',
                        'Manage product types',
                        Icons.label_important_rounded,
                        const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                        ),
                        _isLoading ? '...' : '$_productTypesCount',
                        () => Navigator.of(context).pushNamed('/admin/product-types-list'),
                      ),
                      _buildModernDashboardCard(
                        context,
                        'Products',
                        'Manage inventory',
                        Icons.inventory_2_rounded,
                        const LinearGradient(
                          colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                        ),
                        _isLoading ? '...' : '$_productsCount',
                        () => Navigator.of(context).pushNamed('/admin/products-list'),
                      ),
                    ]),
                  ),
                ),
                
                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Responsive helper methods
  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < 600) return 16.0; // Mobile
    if (screenWidth < 1024) return 24.0; // Tablet
    return 32.0; // Desktop
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) return 1; // Mobile: 1 column
    if (screenWidth < 900) return 2; // Small tablet: 2 columns
    if (screenWidth < 1200) return 2; // Large tablet: 2 columns
    return 3; // Desktop: 3 columns
  }

  double _getGridSpacing(double screenWidth) {
    if (screenWidth < 600) return 16.0; // Mobile
    if (screenWidth < 1024) return 20.0; // Tablet
    return 24.0; // Desktop
  }

  double _getChildAspectRatio(double screenWidth) {
    if (screenWidth < 600) return 2.0; // Mobile: taller cards
    if (screenWidth < 900) return 1.8; // Small tablet
    if (screenWidth < 1200) return 1.6; // Large tablet
    return 1.4; // Desktop: more square cards
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PurviVogueColors.deepNavy,
            PurviVogueColors.deepNavy.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: PurviVogueColors.deepNavy.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purvi Vogue',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: PurviVogueColors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Admin Dashboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PurviVogueColors.roseGold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back! Here\'s what\'s happening with your store today.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PurviVogueColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: PurviVogueColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PurviVogueColors.roseGold.withOpacity(0.3),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.logout_rounded,
                    color: PurviVogueColors.white,
                    size: 24,
                  ),
                  onPressed: () async {
                    await AuthService().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveStatsSection(BuildContext context, bool isMobile, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = _getHorizontalPadding(screenWidth);
    
    if (isMobile) {
      // Mobile: Stack stats vertically
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          children: [
            _buildStatCard(
              context,
              'Total Products',
              _isLoading ? '...' : '$_productsCount',
              Icons.inventory_2_rounded,
              const Color(0xFF43e97b),
              _isLoading ? '...' : '+${(_productsCount * 0.12).round()}%',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Categories',
                    _isLoading ? '...' : '$_categoriesCount',
                    Icons.dashboard_customize_rounded,
                    const Color(0xFF667eea),
                    _isLoading ? '...' : '+${(_categoriesCount * 0.05).round()}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'In Stock',
                    _isLoading ? '...' : '$_inStockCount',
                    Icons.inventory_rounded,
                    const Color(0xFFf093fb),
                    _isLoading ? '...' : '+${(_inStockCount * 0.18).round()}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Tablet and Desktop: Horizontal layout
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Products',
                _isLoading ? '...' : '$_productsCount',
                Icons.inventory_2_rounded,
                const Color(0xFF43e97b),
                _isLoading ? '...' : '+${(_productsCount * 0.12).round()}%',
              ),
            ),
            SizedBox(width: isTablet ? 16 : 20),
            Expanded(
              child: _buildStatCard(
                context,
                'Categories',
                _isLoading ? '...' : '$_categoriesCount',
                Icons.dashboard_customize_rounded,
                const Color(0xFF667eea),
                _isLoading ? '...' : '+${(_categoriesCount * 0.05).round()}%',
              ),
            ),
            SizedBox(width: isTablet ? 16 : 20),
            Expanded(
              child: _buildStatCard(
                context,
                'In Stock',
                _isLoading ? '...' : '$_inStockCount',
                Icons.inventory_rounded,
                const Color(0xFFf093fb),
                _isLoading ? '...' : '+${(_inStockCount * 0.18).round()}%',
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      constraints: BoxConstraints(
        minHeight: isMobile ? 100 : 120,
        maxHeight: isMobile ? 140 : 160,
      ),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: PurviVogueColors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: isMobile ? 15 : 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isMobile ? 18 : 20,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF43e97b).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: const Color(0xFF43e97b),
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: PurviVogueColors.deepNavy,
                      fontWeight: FontWeight.w800,
                      fontSize: isMobile ? 20 : 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PurviVogueColors.charcoal.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: isMobile ? 12 : 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDashboardCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    LinearGradient gradient,
    String count,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        child: Container(
          constraints: BoxConstraints(
            minHeight: isMobile ? 140 : (isTablet ? 160 : 180),
          ),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: isMobile ? 15 : 20,
                offset: Offset(0, isMobile ? 6 : 10),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: isMobile ? 24 : 28,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 12,
                        vertical: isMobile ? 5 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        count,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 18 : 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: isMobile ? 12 : 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: isMobile ? 18 : 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
