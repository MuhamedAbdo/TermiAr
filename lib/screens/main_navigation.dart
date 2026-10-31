import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/about_screen.dart';
import '../utils/bidi_helper.dart';
import 'package:flutter/services.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _quizKeyCounter = 0; // Counter to force QuizScreen recreation

  // Public method to navigate to specific tab
  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
      // Increment counter when navigating to quiz to reset state
      if (index == 2) {
        // Quiz tab index
        _quizKeyCounter++;
      }
    });
  }

  // Build screens dynamically to access navigateToTab
  List<Widget> get _screens => [
    const HomeScreen(),
    const FavoritesScreen(key: ValueKey('favorites')),
    QuizScreen(
      key: ValueKey('quiz_$_quizKeyCounter'),
      onNavigateToHome: () => navigateToTab(0),
    ),
    const AboutScreen(),
  ];

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDarkMode
                ? const Color(0xFF2A2A2A)
                : Colors.white,
            title: BiDiHelper.buildMixedText(
              text: 'تأكيد الخروج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            content: BiDiHelper.buildMixedText(
              text: 'هل تريد حقاً إغلاق التطبيق؟',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: BiDiHelper.buildMixedText(
                  text: 'لا',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0055FF),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0055FF),
                  foregroundColor: Colors.white,
                ),
                child: BiDiHelper.buildMixedText(
                  text: 'نعم',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_currentIndex != 0) {
          // If not on Home tab, go back to Home tab
          setState(() {
            _currentIndex = 0;
          });
        } else {
          // If on Home tab, show exit confirmation dialog
          final shouldExit = await _showExitConfirmation(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          if (isDesktop) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: navigateToTab,
                    labelType: NavigationRailLabelType.all,
                    groupAlignment: -1.0,
                    minWidth: 92,
                    backgroundColor: isDarkMode
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    indicatorColor:
                        const Color(0xFF0055FF).withValues(alpha: 0.15),
                    selectedIconTheme: const IconThemeData(
                      color: Color(0xFF0055FF),
                      size: 26,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      size: 24,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: Color(0xFF0055FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0055FF), Color(0xFF003DCC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0055FF)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.terminal,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          BiDiHelper.buildMixedText(
                            text: 'TermiAr',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: IconButton(
                        icon: Icon(
                          isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: isDarkMode ? Colors.amber : Colors.grey[700],
                        ),
                        tooltip: isDarkMode ? 'الوضع النهاري' : 'الوضع الليلي',
                        mouseCursor: SystemMouseCursors.click,
                        onPressed: () => themeProvider.toggleTheme(),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.home_outlined),
                        ),
                        selectedIcon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.home),
                        ),
                        label: Text('الرئيسية'),
                      ),
                      NavigationRailDestination(
                        icon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.favorite_border),
                        ),
                        selectedIcon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.favorite),
                        ),
                        label: Text('المفضلة'),
                      ),
                      NavigationRailDestination(
                        icon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.quiz_outlined),
                        ),
                        selectedIcon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.quiz),
                        ),
                        label: Text('الاختبار'),
                      ),
                      NavigationRailDestination(
                        icon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.info_outline),
                        ),
                        selectedIcon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Icon(Icons.info),
                        ),
                        label: Text('حول التطبيق'),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: _screens,
                    ),
                  ),
                ],
              ),
            );
          }

          // Mobile Layout (< 800)
          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: _screens),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: navigateToTab,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF0055FF),
                unselectedItemColor: isDarkMode
                    ? Colors.grey[600]
                    : Colors.grey[500],
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(fontSize: 12),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'الرئيسية',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    activeIcon: Icon(Icons.favorite),
                    label: 'المفضلة',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.quiz_outlined),
                    activeIcon: Icon(Icons.quiz),
                    label: 'الاختبار',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.info_outline),
                    activeIcon: Icon(Icons.info),
                    label: 'حول التطبيق',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
