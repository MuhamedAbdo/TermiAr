import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/category_commands_screen.dart';
import '../utils/bidi_helper.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categoriesResponse = await DataService.loadCategories();
      setState(() {
        _categories = categoriesResponse.categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading categories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'terminal':
        return Icons.terminal;
      case 'laptop_linux':
        return Icons.computer;
      case 'settings_system_daydream':
        return Icons.settings_system_daydream;
      case 'folder':
        return Icons.folder;
      case 'lan':
        return Icons.lan;
      case 'analytics':
        return Icons.analytics;
      case 'security':
        return Icons.security;
      default:
        return Icons.category;
    }
  }

  Map<String, dynamic> _getCategoryTheme(String categoryId) {
    switch (categoryId) {
      case 'debian_family':
        return {
          'lightGradient': [const Color(0xFFD70A53), const Color(0xFFA80030)],
          'darkGradient': [const Color(0xFFE5396B), const Color(0xFFC2185B)],
          'borderColor': const Color(0xFF8B0026),
          'shadowColor': const Color(0xFFD70A53).withOpacity(0.3),
        };
      case 'redhat_family':
        return {
          'lightGradient': [const Color(0xFFCC0000), const Color(0xFF990000)],
          'darkGradient': [const Color(0xFFE53935), const Color(0xFFD32F2F)],
          'borderColor': const Color(0xFF990000),
          'shadowColor': const Color(0xFFCC0000).withOpacity(0.3),
        };
      default:
        return {
          'lightGradient': [const Color(0xFF0055FF), const Color(0xFF003DCC)],
          'darkGradient': [const Color(0xFF448AFF), const Color(0xFF2979FF)],
          'borderColor': const Color(0xFF0029CC),
          'shadowColor': const Color(0xFF0055FF).withOpacity(0.3),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأقسام (Categories)'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? _buildEmptyState(isDarkMode)
          : _buildCategoriesList(isDarkMode),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text('لا توجد أقسام حالياً'),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final categoryTheme = _getCategoryTheme(category.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 8,
            shadowColor: categoryTheme['shadowColor'],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: categoryTheme['borderColor']!, width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? categoryTheme['darkGradient']!
                      : categoryTheme['lightGradient']!,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: category.id == 'debian_family'
                      ? SvgPicture.asset(
                          'assets/images/debian_logo_new.svg',
                          width: 40,
                          height: 40,
                        )
                      : category.id == 'redhat_family'
                      ? SvgPicture.asset(
                          'assets/images/redhat_logo_new.svg',
                          width: 40,
                          height: 40,
                        )
                      : Icon(
                          _getIconData(category.icon),
                          color: Colors.white,
                          size: 32,
                        ),
                ),
                title: BiDiHelper.buildMixedText(
                  text: category.name_ar,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    BiDiHelper.buildMixedText(
                      text: category.name_en,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BiDiHelper.buildMixedText(
                      text: category.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CategoryCommandsScreen(
                            categoryId: category.id,
                            categoryName: category.name_ar,
                          ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ),
                              ),
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
