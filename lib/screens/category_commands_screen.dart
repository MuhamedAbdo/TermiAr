import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../screens/command_details_screen.dart';
import '../utils/bidi_helper.dart'; // إضافة المساعد

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCommands();
  }

  Future<void> _loadCommands() async {
    try {
      final commands = await DataService.getCommandsByCategory(widget.categoryId);
      setState(() {
        _commands = commands;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading commands: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _commands.isEmpty
              ? _buildEmptyState(isDarkMode)
              : _buildCommandsList(isDarkMode),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: isDarkMode ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('لا توجد أوامر في هذا القسم حالياً'),
        ],
      ),
    );
  }

  Widget _buildCommandsList(bool isDarkMode) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _commands.length,
      itemBuilder: (context, index) {
        final command = _commands[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF0055FF),
              child: Text(
                command.command[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: BiDiHelper.buildMixedText(
              text: command.command,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BiDiHelper.buildMixedText(
                  text: command.name_ar,
                  style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                BiDiHelper.buildMixedText(
                  text: command.description,
                  style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CommandDetailsScreen(command: command),
              ));
            },
          ),
        );
      },
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'مبتدئ': return Colors.green;
      case 'متوسط': return Colors.orange;
      case 'متقدم': return Colors.red;
      default: return Colors.grey;
    }
  }
}