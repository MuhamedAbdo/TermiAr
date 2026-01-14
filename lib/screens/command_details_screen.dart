import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/bidi_helper.dart'; // إضافة المساعد
import 'package:google_fonts/google_fonts.dart';

class CommandDetailsScreen extends StatefulWidget {
  final CommandModel command;

  const CommandDetailsScreen({super.key, required this.command});

  @override
  State<CommandDetailsScreen> createState() => _CommandDetailsScreenState();
}

class _CommandDetailsScreenState extends State<CommandDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final isFavorite = favoritesProvider.isFavorite(widget.command.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.command.command),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.command.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyCommandToClipboard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الكارت العلوي: اسم الأمر والمستوى
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                          ),
                          child: Center(
                            child: Text(
                              widget.command.command[0].toUpperCase(),
                              style: GoogleFonts.cairo(
                                height: 1.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.command.command,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF1A1A1A),
                                ),
                              ),
                              // استخدام المساعد للاسم العربي
                              BiDiHelper.buildMixedText(
                                text: widget.command.name_ar,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getLevelColor(
                          widget.command.level,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: BiDiHelper.buildMixedText(
                        text: widget.command.level,
                        style: TextStyle(
                          color: _getLevelColor(widget.command.level),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // قسم الصياغة (Syntax) - VS Code Style
            _buildSectionCard(
              context,
              title: 'الصياغة',
              icon: Icons.code,
              isDarkMode: isDarkMode,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // VS Code dark background
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF333333)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Terminal Header - Three colored dots
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF252526),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5F56),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFBD2E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF27C93F),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Syntax Content with Horizontal Scrolling
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          widget.command.syntax,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Color(0xFFD4D4D4), // VS Code text color
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // قسم الوصف (Description) - أهم جزء للتعديل
            _buildSectionCard(
              context,
              title: 'الوصف',
              icon: Icons.description,
              isDarkMode: isDarkMode,
              child: BiDiHelper.buildRichTextWithCommands(
                // ✅ الحل الجذري هنا
                text: widget.command.description,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // قسم كيفية الاستخدام (How to use)
            _buildSectionCard(
              context,
              title: 'كيفية الاستخدام',
              icon: Icons.play_circle,
              isDarkMode: isDarkMode,
              child: BiDiHelper.buildRichTextWithCommands(
                // ✅ الحل الجذري هنا
                text: widget.command.how_to_use,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // زر نسخ الأمر
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copyCodeToClipboard(context),
                icon: const Icon(Icons.copy),
                label: const Text('نسخ الكود'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF0055FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجيت مساعد لبناء الكروت بشكل موحد ومنظم
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDarkMode,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF0055FF)),
                const SizedBox(width: 8),
                BiDiHelper.buildMixedText(
                  text: title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
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

  void _copyCommandToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.command.command));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BiDiHelper.buildMixedText(
          text: 'تم نسخ الأمر',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyCodeToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.command.syntax));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BiDiHelper.buildMixedText(
          text: 'تم نسخ الكود',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
