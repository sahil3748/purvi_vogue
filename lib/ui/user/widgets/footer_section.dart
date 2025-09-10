import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A237E),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          // Main Footer Content
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return _buildDesktopFooter();
              } else {
                return _buildMobileFooter();
              }
            },
          ),

          const Divider(color: Colors.white24, height: 32),

          // Copyright
          Text(
            '© 2024 Purvi Vogue. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFooter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Section
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Purvi Vogue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Discover exquisite jewelry and fashion accessories that define elegance and style.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Quick Links
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Links',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFooterLink('Home', '/user/home'),
              _buildFooterLink('Categories', '/user/categories'),
              _buildFooterLink('Featured', '/user/products'),
              _buildFooterLink('Best Sellers', '/user/products'),
            ],
          ),
        ),

        const SizedBox(width: 48),

        // Contact Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contact Us',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildContactInfo(Icons.email, 'team.purvivogue@gmail.com'),
              _buildContactInfo(Icons.phone, '+91 91067 89974'),
              _buildContactInfo(Icons.location_on, 'Ahmedabad, India'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Section
        const Text(
          'Purvi Vogue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Discover exquisite jewelry and fashion accessories that define elegance and style.',
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
        ),

        const SizedBox(height: 32),

        // Quick Links
        const Text(
          'Quick Links',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildFooterLink('Home', '/user/home')),
            Expanded(child: _buildFooterLink('Categories', '/user/categories')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildFooterLink('Featured', '/user/products')),
            Expanded(child: _buildFooterLink('Best Sellers', '/user/products')),
          ],
        ),

        const SizedBox(height: 32),

        // Contact Info
        const Text(
          'Contact Us',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactInfo(Icons.email, 'info@purvivogue.com'),
        _buildContactInfo(Icons.phone, '+91 98765 43210'),
        _buildContactInfo(Icons.location_on, 'Mumbai, India'),
      ],
    );
  }

  Widget _buildFooterLink(String title, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          // Navigation will be handled by the parent widget
        },
        child: Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
