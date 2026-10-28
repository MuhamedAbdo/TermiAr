import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/command_details_screen.dart';
import '../utils/bidi_helper.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  List<CommandModel> _allCommands = [];

  @override
  void initState() {
    super.initState();
    _loadAllCommands();
  }

  Future<void> _loadAllCommands() async {
    try {
      final allCommandsResponse = await DataService.loadCommands();
      if (mounted) {
        setState(() {
          _allCommands = allCommandsResponse.commands;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allCommands = [];
          _isLoading = false;
        });
      }
    }
  }

  List<CommandModel> _getFavoriteCommands(FavoritesProvider favoritesProvider) {
    if (!favoritesProvider.isInitialized || _isLoading) {
      return [];
    }
    return _allCommands
        .where((command) => favoritesProvider.isFavorite(command.id))
        .toList();
  }

  String _getCategoryDisplayName(String categoryId) {
    switch (categoryId) {
      case 'universal':
      case 'universal_commands':
        return 'أوامر مشتركة';
      case 'debian_family':
        return 'عائلة دبيان';
      case 'redhat_family':
        return 'عائلة ريد هات';
      case 'file_management':
        return 'إدارة الملفات';
      case 'network':
      case 'networking':
        return 'الشبكات والاتصال';
      case 'system_monitor':
      case 'system_administration':
        return 'مراقبة النظام';
      case 'security':
        return 'الأمان والصلاحيات';
      case 'process_management':
        return 'إدارة العمليات';
      case 'flutter_dart':
        return 'فلاتر ودارت';
      case 'android_dev':
        return 'تطوير أندرويد';
      case 'git_github':
        return 'إدارة الإصدارات';
      default:
        return categoryId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          if (!favoritesProvider.isInitialized || _isLoading) {
            return Scaffold(
              appBar: AppBar(title: const Text('المفضلة'), centerTitle: true),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final favoriteCommands = _getFavoriteCommands(favoritesProvider);

          return Scaffold(
            appBar: AppBar(
              title: const Text('المفضلة'),
              centerTitle: true,
              actions: [
                if (favoriteCommands.isNotEmpty)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'clear_all') {
                        _showClearAllConfirmation();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('مسح الكل'),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            body: favoriteCommands.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(favoriteCommands, favoritesProvider),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أوامر مفضلة حتى الآن',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على أيقونة القلب بجانب أي أمر لإضافته إلى قائمتك المفضلة للرجوع إليه بسرعة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/home', (route) => false);
              },
              icon: const Icon(Icons.explore),
              label: const Text('استكشف الأوامر'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0055FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(
    List<CommandModel> favoriteCommands,
    FavoritesProvider favoritesProvider,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: favoriteCommands.length,
      itemBuilder: (context, index) {
        final command = favoriteCommands[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0055FF),
              ),
              child: Text(
                command.command.isNotEmpty
                    ? command.command[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  height: 1.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    command.command,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0055FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getCategoryDisplayName(command.category_id),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0055FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                command.name_ar,
                style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    _deleteFavorite(command);
                  },
                  tooltip: 'إزالة من المفضلة',
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CommandDetailsScreen(command: command),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _deleteFavorite(CommandModel command) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: BiDiHelper.buildMixedText(
          text: 'تأكيد الحذف',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: BiDiHelper.buildMixedText(
          text: 'هل تريد حقاً حذف "${command.command}" من المفضلة؟',
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: BiDiHelper.buildMixedText(
              text: 'إلغاء',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: BiDiHelper.buildMixedText(
              text: 'حذف',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final favoritesProvider = Provider.of<FavoritesProvider>(
        context,
        listen: false,
      );
      await favoritesProvider.toggleFavorite(command.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: BiDiHelper.buildMixedText(
              text: 'تم الحذف من المفضلة',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF0055FF),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showClearAllConfirmation() {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: BiDiHelper.buildMixedText(
          text: 'مسح كل المفضلة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: BiDiHelper.buildMixedText(
          text: 'هل أنت متأكد من رغبتك في حذف جميع الأوامر من قائمتك المفضلة؟',
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: BiDiHelper.buildMixedText(
              text: 'إلغاء',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<FavoritesProvider>(
                context,
                listen: false,
              ).clearAllFavorites();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح جميع الأوامر من المفضلة'),
                  backgroundColor: Color(0xFF0055FF),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: BiDiHelper.buildMixedText(
              text: 'مسح الكل',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
