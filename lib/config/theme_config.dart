import 'package:flutter/material.dart';

class PurviVogueColors {
  // Refined Color Palette
  static const Color deepNavy = Color(0xFF1C1C3C);      // Primary background / header
  static const Color softBeige = Color(0xFFF5F0E6);     // Main background / sections
  static const Color roseGold = Color(0xFFB76E79);      // Accent (buttons, highlights)
  static const Color blushPink = Color(0xFFF4C2C2);     // Secondary accent (hover states)
  static const Color white = Color(0xFFFFFFFF);         // Text & card backgrounds
  static const Color charcoalBlack = Color(0xFF121212); // Optional text / footer
}

class ResponsiveBreakpoints {
  // Mobile breakpoints
  static const double mobileSmall = 320;
  static const double mobileMedium = 375;
  static const double mobileLarge = 414;
  
  // Tablet breakpoints
  static const double tabletSmall = 600;
  static const double tabletMedium = 768;
  static const double tabletLarge = 900;
  
  // Desktop breakpoints
  static const double desktopSmall = 1024;
  static const double desktopMedium = 1200;
  static const double desktopLarge = 1440;
  static const double desktopXLarge = 1920;
}

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.tabletSmall;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tabletSmall && width < ResponsiveBreakpoints.desktopSmall;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktopSmall;
  }
  
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktopLarge;
  }
  
  static double getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 2; // 2 columns on mobile
    } else if (isTablet(context)) {
      return 3; // 3 columns on tablet
    } else if (isLargeScreen(context)) {
      return 5; // 5 columns on large desktop
    } else {
      return 4; // 4 columns on regular desktop
    }
  }
  
  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 0.75; // Taller cards on mobile
    } else {
      return 0.85; // Slightly wider cards on larger screens
    }
  }
  
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }
  
  static double getMaxContentWidth(BuildContext context) {
    if (isLargeScreen(context)) {
      return ResponsiveBreakpoints.desktopXLarge;
    } else if (isDesktop(context)) {
      return ResponsiveBreakpoints.desktopLarge;
    } else {
      return double.infinity;
    }
  }
}

class PurviVogueTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PurviVogueColors.roseGold,
        primary: PurviVogueColors.roseGold,
        secondary: PurviVogueColors.blushPink,
        surface: PurviVogueColors.white,
        background: PurviVogueColors.softBeige,
        onPrimary: PurviVogueColors.white,
        onSecondary: PurviVogueColors.deepNavy,
        onSurface: PurviVogueColors.charcoalBlack,
        onBackground: PurviVogueColors.charcoalBlack,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PurviVogueColors.white,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: PurviVogueColors.white,
        elevation: 4,
        shadowColor: PurviVogueColors.charcoalBlack.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PurviVogueColors.roseGold,
          foregroundColor: PurviVogueColors.white,
          elevation: 2,
          shadowColor: PurviVogueColors.roseGold.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PurviVogueColors.roseGold,
          side: const BorderSide(color: PurviVogueColors.roseGold, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PurviVogueColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PurviVogueColors.blushPink.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: PurviVogueColors.blushPink.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PurviVogueColors.roseGold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: PurviVogueColors.charcoalBlack,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: PurviVogueColors.charcoalBlack,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: PurviVogueColors.charcoalBlack,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: PurviVogueColors.charcoalBlack,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PurviVogueColors.charcoalBlack,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.charcoalBlack,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.charcoalBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.charcoalBlack,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.charcoalBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: PurviVogueColors.charcoalBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: PurviVogueColors.charcoalBlack,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: PurviVogueColors.charcoalBlack,
        ),
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: PurviVogueColors.softBeige,
    );
  }
}
