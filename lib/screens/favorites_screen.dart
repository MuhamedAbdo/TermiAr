import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/command_details_screen.dart';
import '../utils/bidi_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<CommandModel> _favoriteCommands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCommands();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload favorites every time the screen is displayed
    _loadFavoriteCommands();
  }

  Future<void> _loadFavoriteCommands() async {
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );

    // Wait for favorites to be initialized
    while (!favoritesProvider.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    print(
      'Loading favorite commands. Current favorite IDs: ${favoritesProvider.favoriteCommandIds}',
    );

    if (favoritesProvider.favoriteCommandIds.isEmpty) {
      print('No favorites found, showing empty state');
      setState(() {
        _favoriteCommands = [];
        _isLoading = false;
      });
      return;
    }

    try {
      // Load all commands and filter by favorites
      final allCommandsResponse = await DataService.loadCommands();
      final favoriteCommands = allCommandsResponse.commands
          .where((command) => favoritesProvider.isFavorite(command.id))
          .toList();

      print('Found ${favoriteCommands.length} favorite commands');
      for (var command in favoriteCommands) {
        print('Favorite command: ${command.id} - ${command.command}');
      }

      setState(() {
        _favoriteCommands = favoriteCommands;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorite commands: $e');
      setState(() {
        _favoriteCommands = [];
        _isLoading = false;
      });
    }
  }

  String _getCategoryDisplayName(String categoryId) {
    switch (categoryId) {
      case 'debian_family':
        return 'Debian Family';
      case 'redhat_family':
        return 'Red Hat Family';
      case 'universal_commands':
        return 'Universal Commands';
      case 'file_management':
        return 'File Management';
      case 'networking':
        return 'Networking';
      case 'system_administration':
        return 'System Administration';
      case 'security':
        return 'Security';
      case 'process_management':
        return 'Process Management';
      default:
        return categoryId
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) => word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Refresh favorites when user navigates back to this screen
        _loadFavoriteCommands();
        return true;
      },
      child: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final isDarkMode = themeProvider.isDarkMode;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Favorites'),
              centerTitle: true,
              actions: [
                if (_favoriteCommands.isNotEmpty)
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
                        child: Text('Clear All'),
                      ),
                    ],
                  ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _favoriteCommands.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(favoritesProvider),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Center(
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
            'No favorites yet',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on commands to add them to favorites',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to home screen to discover commands
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home', (route) => false);
            },
            icon: const Icon(Icons.explore),
            label: Text('Explore Commands'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0055FF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(FavoritesProvider favoritesProvider) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _favoriteCommands.length,
      itemBuilder: (context, index) {
        final command = _favoriteCommands[index];
        final isFavorite = favoritesProvider.isFavorite(command.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0055FF),
              ),
              child: Text(
                command.command.isNotEmpty
                    ? command.command[0].toUpperCase()
                    : 'C',
                style: GoogleFonts.cairo(
                  height: 1.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  command.command,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0055FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getCategoryDisplayName(command.category_id),
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: const Color(0xFF0055FF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                command.name_ar,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () {
                    _deleteFavorite(command);
                  },
                  tooltip: 'Remove from favorites',
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
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

    // Show confirmation dialog first
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
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: BiDiHelper.buildMixedText(
              text: 'إلغاء',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: BiDiHelper.buildMixedText(
              text: 'حذف',
              style: TextStyle(
                color: Color(0xFF0055FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    // Only proceed if user confirmed
    if (confirmed == true) {
      // Remove from favorites with animation
      setState(() {
        _favoriteCommands.removeWhere((c) => c.id == command.id);
      });

      // Also remove from provider
      final favoritesProvider = Provider.of<FavoritesProvider>(
        context,
        listen: false,
      );
      await favoritesProvider.toggleFavorite(command.id);

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: BiDiHelper.buildMixedText(
              text: 'تم الحذف من المفضلة',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
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
          text: 'Clear All Favorites',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: BiDiHelper.buildMixedText(
          text: 'Are you sure you want to remove all favorites?',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: BiDiHelper.buildMixedText(
              text: 'Cancel',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF0055FF),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<FavoritesProvider>(
                context,
                listen: false,
              ).clearAllFavorites();
              setState(() {
                _favoriteCommands.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: BiDiHelper.buildMixedText(
              text: 'Clear All',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
