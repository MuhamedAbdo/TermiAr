import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/theme_provider.dart';
import '../utils/bidi_helper.dart'; // إضافة المساعد

class CommandDetailsScreen extends StatelessWidget {
  final CommandModel command;

  const CommandDetailsScreen({
    super.key,
    required this.command,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(command.command),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context, command.command),
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
                        CircleAvatar(
                          backgroundColor: const Color(0xFF0055FF),
                          child: Text(
                            command.command[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                command.command,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                ),
                              ),
                              // استخدام المساعد للاسم العربي
                              BiDiHelper.buildMixedText(
                                text: command.name_ar,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getLevelColor(command.level).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: BiDiHelper.buildMixedText(
                        text: command.level,
                        style: TextStyle(
                          color: _getLevelColor(command.level),
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
                  border: Border.all(
                    color: const Color(0xFF333333),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Terminal Header - Three colored dots
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          command.syntax,
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
              child: BiDiHelper.buildRichTextWithCommands( // ✅ الحل الجذري هنا
                text: command.description,
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
              child: BiDiHelper.buildRichTextWithCommands( // ✅ الحل الجذري هنا
                text: command.how_to_use,
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
                onPressed: () => _copyToClipboard(context, command.command),
                icon: const Icon(Icons.copy),
                label: const Text('نسخ الأمر الرئيسي'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF0055FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجيت مساعد لبناء الكروت بشكل موحد ومنظم
  Widget _buildSectionCard(BuildContext context, {
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
      case 'مبتدئ': return Colors.green;
      case 'متوسط': return Colors.orange;
      case 'متقدم': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BiDiHelper.buildMixedText(
          text: 'تم النسخ إلى الحافظة',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}