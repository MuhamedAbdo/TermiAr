import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/category_commands_screen.dart';
import '../utils/bidi_helper.dart'; // إضافة المساعد

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
          SnackBar(content: Text('Error loading categories: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'terminal': return Icons.terminal;
      case 'laptop_linux': return Icons.computer;
      case 'settings_system_daydream': return Icons.settings_system_daydream;
      case 'folder': return Icons.folder;
      case 'lan': return Icons.lan;
      case 'analytics': return Icons.analytics;
      case 'security': return Icons.security;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('الأقسام (Categories)')),
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
          Icon(Icons.category_outlined, size: 64, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
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
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0055FF),
              child: Icon(_getIconData(category.icon), color: Colors.white, size: 24),
            ),
            title: BiDiHelper.buildMixedText(
              text: category.name_ar,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BiDiHelper.buildMixedText(
                  text: category.name_en,
                  style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                BiDiHelper.buildMixedText(
                  text: category.description,
                  style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CategoryCommandsScreen(
                  categoryId: category.id,
                  categoryName: category.name_ar,
                ),
              ));
            },
          ),
        );
      },
    );
  }
}