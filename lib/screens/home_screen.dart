import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/command_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/command_details_screen.dart';
import '../screens/category_commands_screen.dart';
import '../widgets/daily_tip_card.dart';
import '../widgets/app_drawer.dart';
import '../utils/bidi_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CommandModel> _searchResults = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _isSearching = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
    } else {
      setState(() {
        _isSearching = true;
      });
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await DataService.searchCommands(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      // Handle error silently
    }
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
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Menu Button
                      IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        icon: Icon(
                          Icons.menu,
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      // Centered App Title using Expanded and Center
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 48.0), // تعويض مساحة الأيقونة لضمان التوسط الحقيقي
                            child: BiDiHelper.buildMixedText(
                              text: 'TermiAr',
                              style: GoogleFonts.cairo(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Centered Subtitle
                  Center(
                    child: BiDiHelper.buildMixedText(
                      text: 'Your Linux Command Companion',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _searchController,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: 'Search commands...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Daily Tip Section
            if (!_isSearching) const DailyTipCard(),
            
            // Content Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _isSearching
                      ? _buildSearchResults()
                      : _buildCategoriesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCategoriesGrid() and _buildSearchResults() remain the same as previous code
  Widget _buildCategoriesGrid() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell(
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
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getIconData(category.icon), size: 36, color: const Color(0xFF0055FF)),
                    const SizedBox(height: 10),
                    Text(
                      category.name_ar,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      category.name_en,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
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
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No commands found', style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final command = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0055FF),
              child: Text(command.command[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(command.command, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(command.name_ar, style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700])),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CommandDetailsScreen(command: command))),
          ),
        );
      },
    );
  }
}