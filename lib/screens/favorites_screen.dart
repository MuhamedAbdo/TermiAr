import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/command_details_screen.dart';

enum FavoriteSortOption {
  recentAdded,
  nameAsc,
  nameDesc,
  category,
  riskLevel,
  difficulty,
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  List<CommandModel> _allCommands = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _favoritesScrollController = ScrollController();
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  String? _selectedTagFilter;
  FavoriteSortOption _sortOption = FavoriteSortOption.recentAdded;

  @override
  void initState() {
    super.initState();
    _loadAllCommands();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _favoritesScrollController.dispose();
    super.dispose();
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

  List<CommandModel> _filterAndSortFavorites(
    List<CommandModel> commands,
    FavoritesProvider favoritesProvider,
  ) {
    var filtered = commands.where((cmd) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = DataService.normalizeText(_searchQuery);
        final cmdName = DataService.normalizeText(cmd.command);
        final nameAr = DataService.normalizeText(cmd.name_ar);
        final desc = DataService.normalizeText(cmd.description);
        final tag = DataService.normalizeText(favoritesProvider.getCommandTag(cmd.id) ?? '');

        final matches = cmdName.contains(query) ||
            nameAr.contains(query) ||
            desc.contains(query) ||
            tag.contains(query);

        if (!matches) return false;
      }

      // 2. Category Filter
      if (_selectedCategoryFilter != null && _selectedCategoryFilter != 'all') {
        if (cmd.category_id != _selectedCategoryFilter) return false;
      }

      // 3. Tag Filter
      if (_selectedTagFilter != null && _selectedTagFilter != 'all') {
        final cmdTag = favoritesProvider.getCommandTag(cmd.id);
        if (cmdTag != _selectedTagFilter) return false;
      }

      return true;
    }).toList();

    // Sorting
    switch (_sortOption) {
      case FavoriteSortOption.nameAsc:
        filtered.sort((a, b) => a.command.toLowerCase().compareTo(b.command.toLowerCase()));
        break;
      case FavoriteSortOption.nameDesc:
        filtered.sort((a, b) => b.command.toLowerCase().compareTo(a.command.toLowerCase()));
        break;
      case FavoriteSortOption.category:
        filtered.sort((a, b) => a.category_id.compareTo(b.category_id));
        break;
      case FavoriteSortOption.riskLevel:
        int getRiskWeight(String r) {
          switch (r.toLowerCase()) {
            case 'high':
            case 'عالي':
              return 3;
            case 'moderate':
            case 'medium':
            case 'متوسط':
              return 2;
            default:
              return 1;
          }
        }
        filtered.sort((a, b) => getRiskWeight(b.risk_level).compareTo(getRiskWeight(a.risk_level)));
        break;
      case FavoriteSortOption.difficulty:
        int getLevelWeight(String l) {
          switch (l) {
            case 'متقدم':
              return 3;
            case 'متوسط':
              return 2;
            default:
              return 1;
          }
        }
        filtered.sort((a, b) => getLevelWeight(a.level).compareTo(getLevelWeight(b.level)));
        break;
      case FavoriteSortOption.recentAdded:
        filtered.sort((a, b) {
          final dateA = favoritesProvider.getCommandAddedDate(a.id);
          final dateB = favoritesProvider.getCommandAddedDate(b.id);
          return dateB.compareTo(dateA);
        });
        break;
    }

    return filtered;
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

  Color _getLevelColor(String level) {
    switch (level) {
      case 'مبتدئ':
        return Colors.green;
      case 'متوسط':
        return Colors.orange;
      case 'متقدم':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
      case 'عالي':
        return const Color(0xFFE53935);
      case 'moderate':
      case 'medium':
      case 'متوسط':
        return const Color(0xFFFB8C00);
      default:
        return const Color(0xFF43A047);
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

          final allFavoriteCommands = _getFavoriteCommands(favoritesProvider);
          final filteredFavorites = _filterAndSortFavorites(allFavoriteCommands, favoritesProvider);

          return Scaffold(
            appBar: AppBar(
              title: Text('المفضلة (${allFavoriteCommands.length})'),
              centerTitle: true,
              actions: [
                if (allFavoriteCommands.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.sort),
                    tooltip: 'ترتيب الأوامر',
                    onPressed: () => _showSortModal(context),
                  ),
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
              ],
            ),
            body: allFavoriteCommands.isEmpty
                ? _buildEmptyState()
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          _buildSearchAndFilters(
                              allFavoriteCommands, favoritesProvider),
                          Expanded(
                            child: filteredFavorites.isEmpty
                                ? _buildFilteredEmptyState()
                                : _buildFavoritesList(
                                    filteredFavorites, favoritesProvider),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(
    List<CommandModel> allFavorites,
    FavoritesProvider favoritesProvider,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    // Collect available categories and their counts
    final Map<String, int> categoryCounts = {};
    for (final cmd in allFavorites) {
      categoryCounts[cmd.category_id] = (categoryCounts[cmd.category_id] ?? 0) + 1;
    }

    final availableTags = favoritesProvider.getAvailableTags();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث داخل المفضلة أو الوسوم...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              filled: true,
              fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Categories Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('الكل (${allFavorites.length})'),
                  selected: _selectedCategoryFilter == null || _selectedCategoryFilter == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategoryFilter = selected ? 'all' : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...categoryCounts.entries.map((entry) {
                  final catId = entry.key;
                  final count = entry.value;
                  final isSelected = _selectedCategoryFilter == catId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('${_getCategoryDisplayName(catId)} ($count)'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryFilter = selected ? catId : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Tags Filter Chips (if any tag exists)
          if (availableTags.isNotEmpty) ...[
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'الوسوم: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('جميع الوسوم'),
                    selected: _selectedTagFilter == null || _selectedTagFilter == 'all',
                    onSelected: (selected) {
                      setState(() {
                        _selectedTagFilter = selected ? 'all' : null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ...availableTags.map((tag) {
                    final isSelected = _selectedTagFilter == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        avatar: const Icon(Icons.label, size: 14),
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedTagFilter = selected ? tag : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
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
              'اضغط على أيقونة القلب بجانب أي أمر لإضافته إلى قائمتك المفضلة وتصنيفه بوسوم مخصصة للرجوع إليه بسرعة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmptyState() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list_off,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أوامر مفضلة مطابقة للتصفية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategoryFilter = null;
                  _selectedTagFilter = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إلغاء التصفية وإظهار الكل'),
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

    return Scrollbar(
      controller: _favoritesScrollController,
      interactive: true,
      child: ListView.builder(
        controller: _favoritesScrollController,
        padding: const EdgeInsets.all(16.0),
        itemCount: favoriteCommands.length,
        itemBuilder: (context, index) {
          final command = favoriteCommands[index];
          final tag = favoritesProvider.getCommandTag(command.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: isDarkMode ? Colors.white12 : Colors.black12,
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              hoverColor: const Color(0xFF0055FF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommandDetailsScreen(command: command),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0055FF),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0055FF).withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              command.command,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              command.name_ar,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'نسخ الأمر',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: command.command));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم نسخ الأمر: ${command.command}'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: const Color(0xFF0055FF),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        tooltip: 'إزالة من المفضلة',
                        onPressed: () => _deleteFavoriteWithUndo(command, favoritesProvider),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0055FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
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
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getLevelColor(command.level).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          command.level,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getLevelColor(command.level),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Risk Badge (if moderate or high)
                      if (command.risk_level.toLowerCase() != 'low')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getRiskColor(command.risk_level).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            command.risk_level.toLowerCase() == 'high' ? 'عالي الخطورة' : 'متوسط الخطورة',
                            style: TextStyle(
                              fontSize: 11,
                              color: _getRiskColor(command.risk_level),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // Custom Tag / Group Badge
                      InkWell(
                        onTap: () => _showTagDialog(command, favoritesProvider),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tag != null
                                ? Colors.purple.withValues(alpha: 0.15)
                                : (isDarkMode ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: tag != null
                                  ? Colors.purple.withValues(alpha: 0.4)
                                  : (isDarkMode ? Colors.white24 : Colors.black12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                tag != null ? Icons.label : Icons.label_outline,
                                size: 12,
                                color: tag != null ? Colors.purpleAccent : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tag ?? '+ إضافة وسم',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: tag != null
                                      ? (isDarkMode ? Colors.purple[200] : Colors.purple[800])
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

  void _showSortModal(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF242424) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ترتيب قائمة المفضلة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildSortTile('الأحدث إضافة أولاً', FavoriteSortOption.recentAdded, Icons.access_time),
                _buildSortTile('أبجدياً (الأمر A - Z)', FavoriteSortOption.nameAsc, Icons.sort_by_alpha),
                _buildSortTile('أبجدياً (الأمر Z - A)', FavoriteSortOption.nameDesc, Icons.sort_by_alpha),
                _buildSortTile('حسب القسم', FavoriteSortOption.category, Icons.category),
                _buildSortTile('حسب مستوى الخطورة', FavoriteSortOption.riskLevel, Icons.warning_amber),
                _buildSortTile('حسب المستوى التعليمي', FavoriteSortOption.difficulty, Icons.signal_cellular_alt),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(String title, FavoriteSortOption option, IconData icon) {
    final isSelected = _sortOption == option;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF0055FF) : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF0055FF) : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF0055FF)) : null,
      onTap: () {
        setState(() {
          _sortOption = option;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showTagDialog(CommandModel command, FavoritesProvider favoritesProvider) {
    final currentTag = favoritesProvider.getCommandTag(command.id) ?? '';
    final controller = TextEditingController(text: currentTag);
    final availableTags = favoritesProvider.getAvailableTags();
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    final suggestions = ['أوامر العمل', 'سيرفر', 'تطوير', 'مهم', 'مراجعة', 'يومي'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.label, color: Color(0xFF0055FF)),
              const SizedBox(width: 8),
              Text(
                'وسم مخصص: ${command.command}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أضف وسماً أو مجموعة لتنظيم أوامرك المفضلة وتسهيل فرزها:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'اسم الوسم',
                    hintText: 'مثال: أوامر الشبكة، سيرفر، يومي',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'اقتراحات سريعة:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: {
                    ...suggestions,
                    ...availableTags,
                  }.map((suggestedTag) {
                    return ActionChip(
                      label: Text(suggestedTag, style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        controller.text = suggestedTag;
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            if (currentTag.isNotEmpty)
              TextButton(
                onPressed: () {
                  favoritesProvider.setCommandTag(command.id, null);
                  Navigator.pop(context);
                },
                child: const Text('حذف الوسم', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                favoritesProvider.setCommandTag(command.id, controller.text.trim());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0055FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ الوسم'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFavoriteWithUndo(CommandModel command, FavoritesProvider favoritesProvider) {
    final previousTag = favoritesProvider.getCommandTag(command.id);

    favoritesProvider.toggleFavorite(command.id);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إزالة "${command.command}" من المفضلة'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.amberAccent,
          onPressed: () {
            favoritesProvider.toggleFavorite(command.id, tag: previousTag);
          },
        ),
      ),
    );
  }

  void _showClearAllConfirmation() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        title: const Text('مسح كل المفضلة', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في حذف جميع الأوامر والوسوم من قائمتك المفضلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<FavoritesProvider>(context, listen: false).clearAllFavorites();
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
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }
}
