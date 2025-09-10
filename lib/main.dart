import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:purvi_vogue/ui/router.dart';
import 'package:purvi_vogue/config/luxury_theme.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kIsWeb ? 'Purvi Vogue' : 'Purvi Vogue Admin',
      debugShowCheckedModeBanner: false,
      theme: PurviVogueTheme.lightTheme,
      routes: AppRouter.routes,
      initialRoute: kIsWeb ? '/user/home' : '/admin',
      // Handle unknown routes
      onUnknownRoute: (settings) {
        if (kIsWeb) {
          // For web, redirect unknown routes to user home
          return MaterialPageRoute(
            builder: (context) => AppRouter.routes['/user/home']!(context),
          );
        } else {
          // For mobile, redirect to admin auth wrapper
          return MaterialPageRoute(
            builder: (context) => AppRouter.routes['/admin']!(context),
          );
        }
      },
    );
  }
}
