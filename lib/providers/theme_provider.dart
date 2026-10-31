import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    Future.microtask(() => _loadThemeMode());
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeKey,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      // Handle error silently
    }

    notifyListeners();
  }

  // Zorin OS inspired color schemes
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0055FF), // Zorin Blue
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0055FF),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0055FF),
          foregroundColor: Colors.white,
          enabledMouseCursor: SystemMouseCursors.click,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          enabledMouseCursor: SystemMouseCursors.click,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          enabledMouseCursor: SystemMouseCursors.click,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          enabledMouseCursor: SystemMouseCursors.click,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      scrollbarTheme: ScrollbarThemeData(
        interactive: true,
        thickness: const WidgetStatePropertyAll(8.0),
        radius: const Radius.circular(4),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return const Color(0xFF0055FF);
          }
          return Colors.black.withValues(alpha: 0.25);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        selectedIconTheme: const IconThemeData(color: Color(0xFF0055FF)),
        unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
        selectedLabelTextStyle: const TextStyle(
          color: Color(0xFF0055FF),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
        useIndicator: true,
        indicatorColor: const Color(0xFF0055FF).withValues(alpha: 0.15),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0055FF), // Zorin Blue
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0055FF),
          foregroundColor: Colors.white,
          enabledMouseCursor: SystemMouseCursors.click,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          enabledMouseCursor: SystemMouseCursors.click,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          enabledMouseCursor: SystemMouseCursors.click,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          enabledMouseCursor: SystemMouseCursors.click,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
      ),
      scrollbarTheme: ScrollbarThemeData(
        interactive: true,
        thickness: const WidgetStatePropertyAll(8.0),
        radius: const Radius.circular(4),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return const Color(0xFF0055FF);
          }
          return Colors.white.withValues(alpha: 0.3);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedIconTheme: const IconThemeData(color: Color(0xFF0055FF)),
        unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
        selectedLabelTextStyle: const TextStyle(
          color: Color(0xFF0055FF),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
        unselectedLabelTextStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
        useIndicator: true,
        indicatorColor: const Color(0xFF0055FF).withValues(alpha: 0.15),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF404040)),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
      ),
    );
  }
}
