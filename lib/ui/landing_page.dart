import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'package:purvi_vogue/ui/widgets/responsive_wrapper.dart';
import 'package:purvi_vogue/ui/widgets/animated_category_card.dart';
import 'package:purvi_vogue/ui/widgets/animated_button.dart';
import 'package:purvi_vogue/ui/widgets/mobile_menu.dart';
import 'package:purvi_vogue/services/firestore_service.dart';
import 'package:purvi_vogue/models/category.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _showMobileMenu = false;

  List<CategoryModel> _categories = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _startAnimations();
    _loadCategories();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesStream = _firestoreService.watchCategories();
      await for (final categories in categoriesStream) {
        setState(() {
          _categories = categories
              .take(3)
              .toList(); // Take first 3 categories for display
        });
        break; // Take first snapshot
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PurviVogueColors.deepNavy,
                  Color(0xFF2A2A5A),
                  Color(0xFF3A3A6A),
                ],
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header
                  _buildHeader(),

                  // Hero Section
                  _buildHeroSection(),

                  // Categories Section
                  _buildCategoriesSection(),

                  // About Section
                  _buildAboutSection(),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),

          // Mobile Menu Overlay
          if (_showMobileMenu)
            MobileMenu(
              onClose: () {
                setState(() {
                  _showMobileMenu = false;
                });
              },
              onNavigate: () {
                setState(() {
                  _showMobileMenu = false;
                });
                Navigator.of(context).pushNamed('/catalog');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: PurviVogueColors.roseGold.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PurviVogueColors.roseGold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'PURVI VOGUE',
              style: TextStyle(
                color: PurviVogueColors.roseGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      actions: [
        if (!ResponsiveUtils.isMobile(context)) ...[
          _buildNavItem('HOME', true),
          _buildNavItem('SHOP', false),
          _buildNavItem('ABOUT', false),
          _buildNavItem('CONTACT', false),
          const SizedBox(width: 32),
        ] else
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: PurviVogueColors.roseGold,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _showMobileMenu = true;
              });
            },
          ),
      ],
    );
  }

  Widget _buildNavItem(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: isActive
              ? PurviVogueColors.roseGold
              : Colors.white.withOpacity(0.8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SliverToBoxAdapter(
      child: Container(
        height: ResponsiveUtils.isMobile(context) ? 600 : 700,
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Row(
          children: [
            if (!ResponsiveUtils.isMobile(context)) ...[
              // Left side - Text content
              Expanded(
                flex: 1,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ELEVATE',
                          style: TextStyle(
                            color: PurviVogueColors.roseGold,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const Text(
                          'YOUR STYLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Discover the perfect blend of tradition and contemporary fashion. From elegant jewelry to stunning ethnic wear.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 48),
                        AnimatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/catalog'),
                          child: const Text(
                            'SHOP NOW',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
              // Right side - Image
              Expanded(
                flex: 1,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              PurviVogueColors.blushPink.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 120,
                            color: PurviVogueColors.roseGold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Mobile layout
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ELEVATE',
                          style: TextStyle(
                            color: PurviVogueColors.roseGold,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const Text(
                          'YOUR STYLE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Discover the perfect blend of tradition and contemporary fashion.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        AnimatedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/catalog'),
                          child: const Text(
                            'SHOP NOW',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: Container(
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Column(
          children: [
            const SizedBox(height: 60),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'EXPLORE COLLECTIONS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: PurviVogueColors.deepNavy,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover our curated selection of fashion and jewelry',
              style: TextStyle(
                fontSize: 16,
                color: PurviVogueColors.deepNavy.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
            if (_categories.isNotEmpty)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: ResponsiveUtils.isMobile(context) ? 2 : 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
                children: _categories.map((category) {
                  return AnimatedCategoryCard(
                    title: category.name.toUpperCase(),
                    subtitle: category.description ?? 'Explore collection',
                    icon: Icons.category,
                    color: _getCategoryColor(category.name),
                    onTap: () {
                      Navigator.of(context).pushNamed('/catalog');
                    },
                  );
                }).toList(),
              )
            else
              Center(
                child: CircularProgressIndicator(
                  color: PurviVogueColors.roseGold,
                ),
              ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('necklace') || name.contains('jewelry')) {
      return PurviVogueColors.roseGold;
    } else if (name.contains('kurti') || name.contains('dress')) {
      return PurviVogueColors.blushPink;
    } else if (name.contains('earring')) {
      return PurviVogueColors.deepNavy;
    } else {
      return PurviVogueColors.roseGold;
    }
  }

  Widget _buildAboutSection() {
    return SliverToBoxAdapter(
      child: Container(
        color: PurviVogueColors.deepNavy,
        padding: ResponsiveUtils.getScreenPadding(context),
        child: Column(
          children: [
            const SizedBox(height: 60),
            FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'ABOUT US',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: PurviVogueColors.roseGold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.phone,
                  color: PurviVogueColors.roseGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '+128-486-7800',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(width: 32),
                Container(
                  width: 1,
                  height: 20,
                  color: PurviVogueColors.roseGold.withOpacity(0.5),
                ),
                const SizedBox(width: 32),
                const Icon(
                  Icons.email,
                  color: PurviVogueColors.roseGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'info@purvivogue.com',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Text(
              '© 2024 Purvi Vogue. All rights reserved.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.facebook, () {}),
                const SizedBox(width: 24),
                _buildSocialIcon(Icons.camera_alt, () {}),
                const SizedBox(width: 24),
                _buildSocialIcon(Icons.flutter_dash, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PurviVogueColors.roseGold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: PurviVogueColors.roseGold, size: 24),
      ),
    );
  }
}
