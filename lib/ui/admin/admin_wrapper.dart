import 'package:flutter/material.dart';
import 'package:purvi_vogue/services/auth_service.dart';
import 'package:purvi_vogue/ui/admin/admin_login_screen.dart';
import 'package:purvi_vogue/config/theme_config.dart';

class AdminWrapper extends StatefulWidget {
  final Widget child;

  const AdminWrapper({super.key, required this.child});

  @override
  State<AdminWrapper> createState() => _AdminWrapperState();
}

class _AdminWrapperState extends State<AdminWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final isAdmin = await _authService.isAdmin();
      setState(() {
        _isAdmin = isAdmin;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isAdmin = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Redirect web users away from admin pages
    if (!ResponsiveUtils.isMobile(context)) {
      return Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getMaxContentWidth(context),
            ),
            child: Padding(
              padding: ResponsiveUtils.getScreenPadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: PurviVogueColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 64,
                          color: PurviVogueColors.roseGold,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Admin Panel Unavailable',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PurviVogueColors.deepNavy,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Admin functionality is only available on mobile devices for security reasons.',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pushReplacementNamed('/'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PurviVogueColors.roseGold,
                              foregroundColor: PurviVogueColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isAdmin) {
      return const AdminLoginScreen();
    }

    // For mobile devices, wrap the child with navigation layout
    // The child will determine its own route for breadcrumbs
    return widget.child;
  }
}
