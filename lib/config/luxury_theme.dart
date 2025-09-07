import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PurviVogueColors {
  // Luxury Minimalism Color Palette
  static const Color deepNavy = Color(0xFF1A237E); // Primary color
  static const Color roseGold = Color(0xFFE8B4CB); // Secondary color
  static const Color softCream = Color(0xFFFAF8F3); // Background
  static const Color emerald = Color(0xFF00695C); // Success states
  static const Color warmGold = Color(0xFFD4AF37); // Metallic accents
  static const Color deepPlum = Color(0xFF6A1B9A); // Alternative accent
  static const Color blushPink = Color(0xFFF8BBD0); // Soft interactions
  static const Color charcoal = Color(0xFF212121); // Text color
  static const Color white = Color(0xFFFFFFFF); // Pure white
  static const Color error = Color(0xFFB00020); // Error states
}

class PurviVogueTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PurviVogueColors.roseGold,
        primary: PurviVogueColors.deepNavy,
        secondary: PurviVogueColors.roseGold,
        surface: PurviVogueColors.white,
        background: PurviVogueColors.softCream,
        onPrimary: PurviVogueColors.white,
        onSecondary: PurviVogueColors.deepNavy,
        onSurface: PurviVogueColors.charcoal,
        onBackground: PurviVogueColors.charcoal,
        error: PurviVogueColors.error,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: PurviVogueColors.white,
        elevation: 4,
        shadowColor: PurviVogueColors.charcoal.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PurviVogueColors.roseGold,
          foregroundColor: PurviVogueColors.deepNavy,
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
          foregroundColor: PurviVogueColors.deepNavy,
          side: const BorderSide(color: PurviVogueColors.warmGold, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: PurviVogueColors.deepNavy,
        foregroundColor: PurviVogueColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: PurviVogueColors.white),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PurviVogueColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: PurviVogueColors.blushPink.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: PurviVogueColors.roseGold.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: PurviVogueColors.warmGold,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(color: PurviVogueColors.deepNavy),
        floatingLabelStyle: const TextStyle(color: PurviVogueColors.deepNavy),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Text Theme with Playfair Display for headers and Inter for body
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: PurviVogueColors.deepNavy,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: PurviVogueColors.deepNavy,
        ),
        displaySmall: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: PurviVogueColors.deepNavy,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: PurviVogueColors.deepNavy,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PurviVogueColors.deepNavy,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.deepNavy,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.charcoal,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.charcoal,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: PurviVogueColors.charcoal,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 1.5,
          color: PurviVogueColors.charcoal,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          height: 1.5,
          color: PurviVogueColors.charcoal,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          height: 1.5,
          color: PurviVogueColors.charcoal,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PurviVogueColors.warmGold,
        foregroundColor: PurviVogueColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: PurviVogueColors.deepNavy, size: 24),

      // Scaffold Background
      scaffoldBackgroundColor: PurviVogueColors.softCream,

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PurviVogueColors.warmGold,
        linearTrackColor: PurviVogueColors.blushPink,
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return PurviVogueColors.warmGold;
          }
          return PurviVogueColors.deepNavy;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return PurviVogueColors.warmGold;
          }
          return PurviVogueColors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return PurviVogueColors.warmGold.withOpacity(0.5);
          }
          return PurviVogueColors.blushPink.withOpacity(0.5);
        }),
      ),
    );
  }
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
    return MediaQuery.of(context).size.width <
        ResponsiveBreakpoints.tabletSmall;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tabletSmall &&
        width < ResponsiveBreakpoints.desktopSmall;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >=
        ResponsiveBreakpoints.desktopSmall;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >=
        ResponsiveBreakpoints.desktopLarge;
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
