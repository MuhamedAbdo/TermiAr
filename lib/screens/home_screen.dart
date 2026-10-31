import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/command_model.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/data_service.dart';
import '../screens/command_details_screen.dart';
import '../screens/category_commands_screen.dart';
import '../screens/troubleshooting_screen.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/app_drawer.dart';
import '../utils/bidi_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _searchScrollController = ScrollController();
  List<CommandModel> _searchResults = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Filter States
  String? _selectedCategoryId;
  String? _selectedDistro;
  String? _selectedLevel;

  bool get _hasActiveFilters =>
      _selectedCategoryId != null ||
      _selectedDistro != null ||
      _selectedLevel != null;

  bool get _isSearchingOrFiltering =>
      _searchController.text.trim().isNotEmpty || _hasActiveFilters;

  // Filter options mapping
  final Map<String, String> _categoryFilterOptions = {
    'all': 'جميع الأقسام',
    'universal': 'أوامر مشتركة (Universal)',
    'debian_family': 'عائلة دبيان (Debian / Ubuntu)',
    'redhat_family': 'عائلة ريد هات (Red Hat / Fedora)',
    'file_management': 'إدارة الملفات والمجلدات',
    'network': 'الشبكات والاتصال',
    'system_monitor': 'مراقبة النظام والأداء',
    'security': 'الأمان والصلاحيات',
    'flutter_dart': 'فلاتر ودارت (Flutter & Dart)',
    'android_dev': 'تطوير أندرويد (Android & ADB)',
    'git_github': 'إدارة الإصدارات (Git & GitHub)',
  };

  final Map<String, String> _distroFilterOptions = {
    'all': 'جميع التوزيعات',
    'universal': 'أوامر عامة (Universal)',
    'debian': 'دبيان وأوبنتو (Debian / Ubuntu)',
    'redhat': 'ريد هات وفيدورا (RHEL / Fedora)',
    'arch': 'آرش لينكس (Arch Linux)',
  };

  final Map<String, String> _levelFilterOptions = {
    'all': 'جميع المستويات',
    'مبتدئ': 'مبتدئ (Beginner)',
    'متوسط': 'متوسط (Intermediate)',
    'متقدم': 'متقدم (Advanced)',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _categoryScrollController.dispose();
    _searchScrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty && !_hasActiveFilters) {
      if (mounted) {
        setState(() {
          _searchResults.clear();
        });
      }
      return;
    }

    try {
      final results = await DataService.searchCommands(
        query,
        categoryId: _selectedCategoryId,
        distro: _selectedDistro,
        level: _selectedLevel,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedDistro = null;
      _selectedLevel = null;
      _searchController.clear();
      _searchResults.clear();
    });
  }

  Future<void> _loadData() async {
    try {
      final categoriesResponse = await DataService.loadCategories();
      setState(() {
        _categories = categoriesResponse.categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل البيانات: $e'),
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

  Color _getLevelColor(String level) {
    switch (level) {
      case 'مبتدئ':
        return const Color(0xFF43A047);
      case 'متوسط':
        return const Color(0xFFFB8C00);
      case 'متقدم':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                // Header Section: Title, Search, and Filters
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // زر القائمة الجانبية
                          IconButton(
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            tooltip: 'القائمة الجانبية',
                            mouseCursor: SystemMouseCursors.click,
                            icon: Icon(
                              Icons.menu,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          // عنوان التطبيق في المنتصف
                          Expanded(
                            child: Column(
                              children: [
                                BiDiHelper.buildMixedText(
                                  text: 'TermiAr',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                BiDiHelper.buildMixedText(
                                  text: 'دليلك الشامل لأوامر لينكس',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // عنصر موازن لأيقونة القائمة لتوسيط العنوان تماماً
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // شريط البحث الذكي
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'ابحث عن أمر، صياغة، أو شرح باللغة العربية...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDarkMode
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                            ),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF0055FF)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    mouseCursor: SystemMouseCursors.click,
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // شريط الفلاتر السريعة (Filter Chips Bar)
                      _buildFilterChipsBar(isDarkMode),
                    ],
                  ),
                ),

                // كارت نصيحة اليوم (يختفي عند البحث أو التصفية لتوفير المساحة)
                if (!_isSearchingOrFiltering) const DailyTipCard(),

                // شريط دليل حل المشكلات والتشخيص
                if (!_isSearchingOrFiltering)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TroubleshootingScreen(),
                          ),
                        );
                      },
                      mouseCursor: SystemMouseCursors.click,
                      hoverColor:
                          const Color(0xFF0055FF).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF0055FF).withValues(alpha: 0.12)
                              : const Color(0xFF0055FF).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0055FF)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0055FF)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.build_circle_outlined,
                                  color: Color(0xFF0055FF), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'دليل حل المشكلات (Troubleshooting)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF003DCC),
                                    ),
                                  ),
                                  Text(
                                    'إرشادات تشخيصية وأوامر حلول خطوة بخطوة',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                size: 14, color: Color(0xFF0055FF)),
                          ],
                        ),
                      ),
                    ),
                  ),

                // قسم المحتوى الرئيسي: نتائج البحث أو شبكة الأقسام
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _isSearchingOrFiltering
                          ? _buildSearchResults()
                          : _buildCategoriesGrid(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChipsBar(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          // فلتر القسم
          _buildFilterChip(
            label: _selectedCategoryId != null
                ? _categoryFilterOptions[_selectedCategoryId] ?? 'القسم'
                : 'القسم',
            icon: Icons.category_outlined,
            isSelected: _selectedCategoryId != null,
            isDarkMode: isDarkMode,
            onTap: () => _showFilterBottomSheet(
              title: 'تصفية حسب القسم',
              options: _categoryFilterOptions,
              currentValue: _selectedCategoryId,
              onSelected: (val) {
                setState(() => _selectedCategoryId = val);
                _performSearch();
              },
            ),
            onClear: () {
              setState(() => _selectedCategoryId = null);
              _performSearch();
            },
          ),
          const SizedBox(width: 8),

          // فلتر التوزيعة
          _buildFilterChip(
            label: _selectedDistro != null
                ? _distroFilterOptions[_selectedDistro] ?? 'التوزيعة'
                : 'التوزيعة',
            icon: Icons.devices_outlined,
            isSelected: _selectedDistro != null,
            isDarkMode: isDarkMode,
            onTap: () => _showFilterBottomSheet(
              title: 'تصفية حسب التوزيعة',
              options: _distroFilterOptions,
              currentValue: _selectedDistro,
              onSelected: (val) {
                setState(() => _selectedDistro = val);
                _performSearch();
              },
            ),
            onClear: () {
              setState(() => _selectedDistro = null);
              _performSearch();
            },
          ),
          const SizedBox(width: 8),

          // فلتر المستوى
          _buildFilterChip(
            label: _selectedLevel != null
                ? _levelFilterOptions[_selectedLevel] ?? 'المستوى'
                : 'المستوى',
            icon: Icons.signal_cellular_alt,
            isSelected: _selectedLevel != null,
            isDarkMode: isDarkMode,
            onTap: () => _showFilterBottomSheet(
              title: 'تصفية حسب مستوى الصعوبة',
              options: _levelFilterOptions,
              currentValue: _selectedLevel,
              onSelected: (val) {
                setState(() => _selectedLevel = val);
                _performSearch();
              },
            ),
            onClear: () {
              setState(() => _selectedLevel = null);
              _performSearch();
            },
          ),

          // زر إعادة ضبط كل الفلاتر
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: ActionChip(
                avatar: const Icon(Icons.refresh,
                    size: 16, color: Colors.redAccent),
                label: const Text(
                  'إعادة ضبط',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                side: const BorderSide(color: Colors.redAccent, width: 0.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                onPressed: _clearAllFilters,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    final activeColor = const Color(0xFF0055FF);

    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      hoverColor: activeColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : (isDarkMode ? Colors.grey[850] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDarkMode ? Colors.white12 : Colors.black12),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? activeColor
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? activeColor
                      : (isDarkMode ? Colors.white70 : Colors.black87),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            if (isSelected)
              GestureDetector(
                onTap: onClear,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 2.0),
                    child: Icon(Icons.close, size: 15, color: Color(0xFF0055FF)),
                  ),
                ),
              )
            else
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet({
    required String title,
    required Map<String, String> options,
    required String? currentValue,
    required ValueChanged<String?> onSelected,
  }) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF242424) : Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentValue != null)
                      TextButton(
                        onPressed: () {
                          onSelected(null);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          enabledMouseCursor: SystemMouseCursors.click,
                        ),
                        child: const Text('إلغاء التحديد'),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: options.entries.map((entry) {
                    final isSelected = entry.key == 'all'
                        ? currentValue == null
                        : currentValue == entry.key;

                    return ListTile(
                      mouseCursor: SystemMouseCursors.click,
                      dense: true,
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF0055FF)
                              : (isDarkMode ? Colors.white : Colors.black87),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: Color(0xFF0055FF), size: 18)
                          : null,
                      onTap: () {
                        onSelected(entry.key == 'all' ? null : entry.key);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int crossAxisCount;
          final double childAspectRatio;

          if (width < 600) {
            // Mobile: 2 columns
            crossAxisCount = 2;
            childAspectRatio = 1.1;
          } else if (width < 850) {
            // Tablet: 3 columns
            crossAxisCount = 3;
            childAspectRatio = 1.15;
          } else if (width < 1100) {
            // Desktop: 4 columns
            crossAxisCount = 4;
            childAspectRatio = 1.2;
          } else {
            // Desktop (Wide): 5 columns
            crossAxisCount = 5;
            childAspectRatio = 1.25;
          }

          return Scrollbar(
            controller: _categoryScrollController,
            interactive: true,
            child: GridView.builder(
              controller: _categoryScrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _CategoryCardItem(
                  category: category,
                  isDarkMode: isDarkMode,
                  getIconData: _getIconData,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

        if (_searchResults.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لم يتم العثور على أوامر تطابق بحثك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'جرب البحث بكلمات أخرى أو تعديل خيارات التصفية النشطة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة ضبط البحث والتصفية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055FF),
                      foregroundColor: Colors.white,
                      enabledMouseCursor: SystemMouseCursors.click,
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

        return Column(
          children: [
            // شريط إحصائي بعدد النتائج
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  Text(
                    'النتائج (${_searchResults.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (_hasActiveFilters)
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.clear, size: 14),
                      label: const Text(
                        'مسح الفلاتر',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Colors.redAccent,
                        enabledMouseCursor: SystemMouseCursors.click,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _searchScrollController,
                interactive: true,
                child: ListView.builder(
                  controller: _searchScrollController,
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final command = _searchResults[index];
                    final isFavorite =
                        favoritesProvider.isFavorite(command.id);

                    return _SearchResultTile(
                      command: command,
                      isFavorite: isFavorite,
                      isDarkMode: isDarkMode,
                      levelColor: _getLevelColor(command.level),
                      onFavoriteToggle: () {
                        favoritesProvider.toggleFavorite(command.id);
                      },
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CommandDetailsScreen(command: command),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryCardItem extends StatefulWidget {
  final CategoryModel category;
  final bool isDarkMode;
  final IconData Function(String) getIconData;

  const _CategoryCardItem({
    required this.category,
    required this.isDarkMode,
    required this.getIconData,
  });

  @override
  State<_CategoryCardItem> createState() => _CategoryCardItemState();
}

class _CategoryCardItemState extends State<_CategoryCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final category = widget.category;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform:
            Matrix4.translationValues(0.0, _isHovered ? -3.0 : 0.0, 0.0),
        child: Card(
          elevation: _isHovered ? 6 : 2,
          shadowColor: const Color(0xFF0055FF)
              .withValues(alpha: _isHovered ? 0.25 : 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: _isHovered
                  ? const Color(0xFF0055FF).withValues(alpha: 0.6)
                  : (isDarkMode ? Colors.white12 : Colors.black12),
              width: _isHovered ? 1.5 : 1.0,
            ),
          ),
          color: _isHovered
              ? (isDarkMode
                  ? const Color(0xFF303030)
                  : const Color(0xFFF3F7FF))
              : (isDarkMode ? const Color(0xFF242424) : Colors.white),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryCommandsScreen(
                    categoryId: category.id,
                    categoryName: category.name_ar,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (category.id == 'debian_family')
                    SvgPicture.asset(
                      'assets/images/debian_official_logo.svg',
                      width: 36,
                      height: 36,
                    )
                  else if (category.id == 'redhat_family')
                    SvgPicture.asset(
                      'assets/images/redhat_official_logo.svg',
                      width: 36,
                      height: 36,
                    )
                  else if (category.id == 'flutter_dart')
                    SvgPicture.asset(
                      'assets/images/flutter_official_logo.svg',
                      width: 36,
                      height: 36,
                    )
                  else if (category.id == 'android_dev')
                    SvgPicture.asset(
                      'assets/images/android_official_logo.svg',
                      width: 36,
                      height: 36,
                    )
                  else if (category.id == 'git_github')
                    SvgPicture.asset(
                      'assets/images/git_official_logo.svg',
                      width: 36,
                      height: 36,
                    )
                  else
                    Icon(
                      widget.getIconData(category.icon),
                      size: 36,
                      color: const Color(0xFF0055FF),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    category.name_ar,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    category.name_en,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatefulWidget {
  final CommandModel command;
  final bool isFavorite;
  final bool isDarkMode;
  final Color levelColor;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.command,
    required this.isFavorite,
    required this.isDarkMode,
    required this.levelColor,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF0055FF).withValues(alpha: 0.5)
                : (widget.isDarkMode ? Colors.white12 : Colors.black12),
            width: _isHovered ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
              blurRadius: _isHovered ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: _isHovered
              ? (widget.isDarkMode
                  ? const Color(0xFF2E2E2E)
                  : const Color(0xFFF7FAFF))
              : (widget.isDarkMode ? const Color(0xFF242424) : Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            leading: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0055FF),
              ),
              child: Center(
                child: Text(
                  widget.command.command.isNotEmpty
                      ? widget.command.command[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    height: 1.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.command.command,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.levelColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.command.level.isNotEmpty
                        ? widget.command.level
                        : 'مبتدئ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: widget.levelColor,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                widget.command.name_ar,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isDarkMode
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  icon: Icon(
                    widget.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.isFavorite ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: widget.onFavoriteToggle,
                ),
                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
            onTap: widget.onTap,
          ),
        ),
      ),
    );
  }
}
