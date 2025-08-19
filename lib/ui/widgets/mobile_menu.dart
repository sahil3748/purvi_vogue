import 'package:flutter/material.dart';
import 'package:purvi_vogue/config/theme_config.dart';

class MobileMenu extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const MobileMenu({
    super.key,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  State<MobileMenu> createState() => _MobileMenuState();
}

class _MobileMenuState extends State<MobileMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeMenu() {
    _controller.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                ),
              ),
            ),
            
            // Menu
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Transform.translate(
                offset: Offset(
                  MediaQuery.of(context).size.width * 0.2 * _slideAnimation.value,
                  0,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: PurviVogueColors.deepNavy,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: PurviVogueColors.roseGold.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _closeMenu,
                              icon: const Icon(
                                Icons.close,
                                color: PurviVogueColors.roseGold,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Menu Items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            _buildMenuItem(
                              icon: Icons.home,
                              title: 'HOME',
                              onTap: () {
                                _closeMenu();
                                widget.onNavigate();
                              },
                            ),
                            _buildMenuItem(
                              icon: Icons.shopping_cart,
                              title: 'SHOP',
                              onTap: () {
                                _closeMenu();
                                widget.onNavigate();
                              },
                            ),
                            _buildMenuItem(
                              icon: Icons.info,
                              title: 'ABOUT',
                              onTap: () {
                                _closeMenu();
                                widget.onNavigate();
                              },
                            ),
                            _buildMenuItem(
                              icon: Icons.contact_support,
                              title: 'CONTACT',
                              onTap: () {
                                _closeMenu();
                                widget.onNavigate();
                              },
                            ),
                            const SizedBox(height: 32),
                            
                            // Divider
                            Container(
                              height: 1,
                              color: PurviVogueColors.roseGold.withOpacity(0.3),
                            ),
                            const SizedBox(height: 32),
                            
                            // Social Links
                            const Text(
                              'FOLLOW US',
                              style: TextStyle(
                                color: PurviVogueColors.roseGold,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSocialIcon(Icons.facebook, () {}),
                                _buildSocialIcon(Icons.camera_alt, () {}),
                                _buildSocialIcon(Icons.flutter_dash, () {}),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: PurviVogueColors.roseGold,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
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
        child: Icon(
          icon,
          color: PurviVogueColors.roseGold,
          size: 24,
        ),
      ),
    );
  }
}
