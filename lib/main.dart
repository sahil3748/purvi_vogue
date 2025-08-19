import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purvi_vogue/ui/router.dart';
import 'package:purvi_vogue/ui/splash_screen.dart';
import 'package:purvi_vogue/config/theme_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purvi Vogue',
      theme: PurviVogueTheme.lightTheme,
      routes: AppRouter.routes,
      home: _showSplash 
        ? SplashScreen(onSplashComplete: _onSplashComplete)
        : const LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PurviVogueColors.deepNavy,
              PurviVogueColors.roseGold.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getMaxContentWidth(context),
              ),
              child: Padding(
                padding: ResponsiveUtils.getScreenPadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      padding: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 20 : 24),
                      decoration: BoxDecoration(
                        color: PurviVogueColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: ResponsiveUtils.isMobile(context) ? 48 : 64,
                          height: ResponsiveUtils.isMobile(context) ? 48 : 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),
                    
                    // Title
                    Text(
                      'Purvi Vogue',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: PurviVogueColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.isMobile(context) ? 28 : 36,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fashion & Lifestyle',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: PurviVogueColors.white.withOpacity(0.9),
                        fontSize: ResponsiveUtils.isMobile(context) ? 16 : 20,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.isMobile(context) ? 32 : 48),
                    
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          // Customer Catalog Button
                          SizedBox(
                            width: double.infinity,
                            height: ResponsiveUtils.isMobile(context) ? 48 : 56,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pushNamed('/catalog'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PurviVogueColors.white,
                                foregroundColor: PurviVogueColors.deepNavy,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_cart),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Browse Catalog',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: ResponsiveUtils.isMobile(context) ? 14 : 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Admin Panel Button - Only show on mobile
                          if (ResponsiveUtils.isMobile(context))
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pushNamed('/admin/login'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: PurviVogueColors.white,
                                  side: const BorderSide(color: PurviVogueColors.white, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.admin_panel_settings),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Admin Panel',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),
                    
                    // Footer
                    Text(
                      '© 2024 Purvi Vogue. All rights reserved.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PurviVogueColors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
