import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/command_details_screen.dart';
import '../utils/bidi_helper.dart';

class CategoryCommandsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryCommandsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryCommandsScreen> createState() => _CategoryCommandsScreenState();
}

class _CategoryCommandsScreenState extends State<CategoryCommandsScreen> {
  List<CommandModel> _commands = [];
  List<CommandModel> _filteredCommands = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCommands();
    _searchController.addListener(_filterCommands);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCommands() async {
    try {
      final commands = await DataService.getCommandsByCategory(
        widget.categoryId,
      );
      setState(() {
        _commands = commands;
        _filteredCommands = commands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading commands: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final categoryTheme = _getCategoryTheme(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? categoryTheme['darkGradient']!
                  : categoryTheme['lightGradient']!,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Watermark background
          if (widget.categoryId == 'debian_family' ||
              widget.categoryId == 'redhat_family')
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.categoryId == 'debian_family'
                      ? const Color(0xFFD70A53)
                      : const Color(0xFFCC0000).withOpacity(0.03),
                ),
                child: Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Icon(
                      widget.categoryId == 'debian_family'
                          ? Icons.computer
                          : Icons.security,
                      size: 80,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),
          // Main content
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(isDarkMode, categoryTheme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, {bool isSearchResult = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.folder_open,
            size: 64,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isSearchResult
                ? 'لا توجد أوامر تطابق بحثك'
                : 'لا توجد أوامر في هذا القسم حالياً',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDarkMode, Map<String, dynamic> categoryTheme) {
    return Column(
      children: [
        _buildSearchBar(isDarkMode, categoryTheme),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredCommands.isEmpty
              ? _buildEmptyState(
                  isDarkMode,
                  isSearchResult: _searchController.text.isNotEmpty,
                )
              : _buildCommandsList(isDarkMode, categoryTheme),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDarkMode, Map<String, dynamic> categoryTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          hintText: 'ابحث عن أمر...',
          prefixIcon: Icon(Icons.search, color: categoryTheme['borderColor']),
          suffixIcon: null,
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: categoryTheme['borderColor']!,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: categoryTheme['borderColor']!,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  void _filterCommands() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredCommands = _commands;
      } else {
        _filteredCommands = _commands.where((command) {
          return command.command.toLowerCase().contains(query) ||
              command.name_ar.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Widget _buildCommandsList(
    bool isDarkMode,
    Map<String, dynamic> categoryTheme,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _filteredCommands.length,
      itemBuilder: (context, index) {
        final command = _filteredCommands[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 4,
            shadowColor: categoryTheme['shadowColor'],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: categoryTheme['borderColor']!.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? categoryTheme['darkGradient']!
                        : categoryTheme['lightGradient']!,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  command.command[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              title: BiDiHelper.buildMixedText(
                text: command.command,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BiDiHelper.buildMixedText(
                    text: command.name_ar,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  BiDiHelper.buildMixedText(
                    text: command.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(command.level).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: BiDiHelper.buildMixedText(
                      text: command.level,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getLevelColor(command.level),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryTheme['borderColor']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: categoryTheme['borderColor'],
                  size: 16,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        CommandDetailsScreen(command: command),
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
        );
      },
    );
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
        return Colors.grey;
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
}
