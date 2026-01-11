import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/about_screen.dart';
import '../utils/bidi_helper.dart';
import 'package:google_fonts/google_fonts.dart';
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
    const CategoriesScreen(),
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
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            content: BiDiHelper.buildMixedText(
              text: 'هل تريد حقاً إغلاق التطبيق؟',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: BiDiHelper.buildMixedText(
                  text: 'لا',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF0055FF),
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
                  style: GoogleFonts.cairo(
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
      onPopInvoked: (didPop) async {
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
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
                // Increment counter when navigating to quiz to reset state
                if (index == 2) {
                  // Quiz tab index
                  _quizKeyCounter++;
                }
              });
            },
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
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_outlined),
                activeIcon: Icon(Icons.category),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz),
                label: 'Quiz',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                activeIcon: Icon(Icons.info),
                label: 'About',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
