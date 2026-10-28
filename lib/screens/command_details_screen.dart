import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/command_model.dart';
import '../providers/theme_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/bidi_helper.dart';

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
            tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            onPressed: () {
              favoritesProvider.toggleFavorite(widget.command.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'نسخ اسم الأمر',
            onPressed: () => _copyToClipboard(
              context,
              widget.command.command,
              'تم نسخ اسم الأمر',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الكارت العلوي: اسم الأمر، المستوى، ومستوى الخطورة
            _buildHeaderCard(context, isDarkMode),

            const SizedBox(height: 16),

            // صندوق التحذير الأمني إذا وُجد أو إذا كان الأمر عالي الخطورة
            if (widget.command.warning.isNotEmpty ||
                widget.command.risk_level.toLowerCase() == 'high') ...[
              _buildWarningCard(context, isDarkMode),
              const SizedBox(height: 16),
            ],

            // قسم الصياغة (Syntax) - نمط الطرفية
            _buildSyntaxCard(context, isDarkMode),

            const SizedBox(height: 16),

            // قسم الوصف (Description)
            _buildSectionCard(
              context,
              title: 'الوصف',
              icon: Icons.description,
              isDarkMode: isDarkMode,
              child: BiDiHelper.buildRichTextWithCommands(
                text: widget.command.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // قسم كيفية الاستخدام (How to use)
            if (widget.command.how_to_use.isNotEmpty) ...[
              _buildSectionCard(
                context,
                title: 'كيفية الاستخدام',
                icon: Icons.play_circle_outline,
                isDarkMode: isDarkMode,
                child: BiDiHelper.buildRichTextWithCommands(
                  text: widget.command.how_to_use,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // قسم الخيارات والمعاملات (Options & Arguments)
            if (widget.command.options.isNotEmpty) ...[
              _buildOptionsCard(context, isDarkMode),
              const SizedBox(height: 16),
            ],

            // قسم الأمثلة العملية (Practical Examples)
            if (widget.command.examples.isNotEmpty) ...[
              _buildExamplesCard(context, isDarkMode),
              const SizedBox(height: 16),
            ],

            // قسم التوزيعات المدعومة (Supported Distros)
            if (widget.command.distros.isNotEmpty) ...[
              _buildDistrosCard(context, isDarkMode),
              const SizedBox(height: 16),
            ],

            // قسم النتيجة والمخرجات المتوقعة (Expected Results)
            if (widget.command.expected_result.isNotEmpty) ...[
              _buildExpectedResultCard(context, isDarkMode),
              const SizedBox(height: 16),
            ],

            // قسم الأخطاء الشائعة وحلولها (Common Errors)
            if (widget.command.common_errors.isNotEmpty) ...[
              _buildCommonErrorsCard(context, isDarkMode),
              const SizedBox(height: 16),
            ],

            // زر نسخ الأمر الأساسي
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _copyToClipboard(
                  context,
                  widget.command.syntax,
                  'تم نسخ صيغة الأمر',
                ),
                icon: const Icon(Icons.copy),
                label: const Text(
                  'نسخ صيغة الأمر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF0055FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
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
                        fontSize: 22,
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
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      BiDiHelper.buildMixedText(
                        text: widget.command.name_ar,
                        style: TextStyle(
                          fontSize: 15,
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // شارة المستوى
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getLevelColor(
                      widget.command.level,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getLevelColor(
                        widget.command.level,
                      ).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 14,
                        color: _getLevelColor(widget.command.level),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.command.level.isNotEmpty
                            ? widget.command.level
                            : 'مبتدئ',
                        style: TextStyle(
                          color: _getLevelColor(widget.command.level),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // شارة مستوى الخطورة
                _buildRiskBadge(widget.command.risk_level),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    final lowerRisk = risk.toLowerCase();
    Color color;
    String label;
    IconData icon;

    switch (lowerRisk) {
      case 'high':
      case 'عالي':
      case 'خطير':
        color = const Color(0xFFE53935);
        label = 'عالي الخطورة';
        icon = Icons.warning_rounded;
        break;
      case 'moderate':
      case 'medium':
      case 'متوسط':
        color = const Color(0xFFFB8C00);
        label = 'متوسط الخطورة';
        icon = Icons.info_outline;
        break;
      case 'low':
      case 'منخفض':
      default:
        color = const Color(0xFF43A047);
        label = 'آمن / منخفض';
        icon = Icons.verified_user_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, bool isDarkMode) {
    final isHighRisk = widget.command.risk_level.toLowerCase() == 'high';
    final warningColor = isHighRisk ? const Color(0xFFE53935) : const Color(0xFFFB8C00);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: warningColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHighRisk ? Icons.dangerous_rounded : Icons.warning_amber_rounded,
            color: warningColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHighRisk
                      ? 'تحذير أمني شديد — أمر عالي الخطورة'
                      : 'تنبيه أمني وملاحظة هامة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: warningColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (isHighRisk) ...[
                  BiDiHelper.buildMixedText(
                    text:
                        'تنبيه: هذا الأمر قد يسبب أضراراً لا يمكن تداركها للنظام أو حذفاً نهائياً للملفات! لا تقم بتنفيذه دون فهم دقيق لكافة معاملاته وتبعاته.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (widget.command.warning.isNotEmpty) const SizedBox(height: 6),
                ],
                if (widget.command.warning.isNotEmpty)
                  BiDiHelper.buildMixedText(
                    text: widget.command.warning,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectedResultCard(BuildContext context, bool isDarkMode) {
    return _buildSectionCard(
      context,
      title: 'النتيجة والمخرجات المتوقعة',
      icon: Icons.output_rounded,
      isDarkMode: isDarkMode,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // نمط الطرفية
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? Colors.white12 : Colors.black12,
          ),
        ),
        child: BiDiHelper.buildRichTextWithCommands(
          text: widget.command.expected_result,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Color(0xFFD4D4D4),
          ),
        ),
      ),
    );
  }

  Widget _buildCommonErrorsCard(BuildContext context, bool isDarkMode) {
    return _buildSectionCard(
      context,
      title: 'الأخطاء الشائعة وحلولها',
      icon: Icons.bug_report_outlined,
      isDarkMode: isDarkMode,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFB8C00).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFFB8C00).withValues(alpha: 0.3),
          ),
        ),
        child: BiDiHelper.buildRichTextWithCommands(
          text: widget.command.common_errors,
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSyntaxCard(BuildContext context, bool isDarkMode) {
    return _buildSectionCard(
      context,
      title: 'الصياغة (Syntax)',
      icon: Icons.terminal,
      isDarkMode: isDarkMode,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // VS Code / Terminal style
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // شريط الطرفية العلوي بنقاط التحكم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF252526),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5F56),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFBD2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27C93F),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'نسخ الصياغة',
                    onPressed: () => _copyToClipboard(
                      context,
                      widget.command.syntax,
                      'تم نسخ صيغة الأمر',
                    ),
                  ),
                ],
              ),
            ),
            // محتوى الصياغة
            Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  widget.command.syntax,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Color(0xFFD4D4D4),
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(BuildContext context, bool isDarkMode) {
    return _buildSectionCard(
      context,
      title: 'الخيارات والمعاملات (Options)',
      icon: Icons.tune,
      isDarkMode: isDarkMode,
      child: Column(
        children: widget.command.options.map((option) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0055FF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF0055FF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    option.flag,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF0055FF),
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BiDiHelper.buildMixedText(
                    text: option.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExamplesCard(BuildContext context, bool isDarkMode) {
    return _buildSectionCard(
      context,
      title: 'أمثلة عملية (Examples)',
      icon: Icons.lightbulb_outline,
      isDarkMode: isDarkMode,
      child: Column(
        children: widget.command.examples.map((example) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مربع الأمر مع زر النسخ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            example.command,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: Color(0xFF4FC1FF), // VS Code cyan command color
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'نسخ المثال',
                        onPressed: () => _copyToClipboard(
                          context,
                          example.command,
                          'تم نسخ المثال',
                        ),
                      ),
                    ],
                  ),
                ),
                // الشرح باللغة العربية
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: BiDiHelper.buildMixedText(
                    text: example.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDistrosCard(BuildContext context, bool isDarkMode) {
    return _buildSectionCard(
      context,
      title: 'التوزيعات المتوافقة',
      icon: Icons.layers_outlined,
      isDarkMode: isDarkMode,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.command.distros.map((distro) {
          final isUniversal = distro.contains('Universal') || distro.contains('جميع');
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isUniversal
                  ? const Color(0xFF0055FF).withValues(alpha: 0.15)
                  : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUniversal
                    ? const Color(0xFF0055FF)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUniversal ? Icons.check_circle_outline : Icons.computer,
                  size: 14,
                  color: isUniversal
                      ? const Color(0xFF0055FF)
                      : (isDarkMode ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(width: 6),
                Text(
                  distro,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isUniversal ? FontWeight.bold : FontWeight.normal,
                    color: isUniversal
                        ? const Color(0xFF0055FF)
                        : (isDarkMode ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

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
                Icon(icon, color: const Color(0xFF0055FF), size: 20),
                const SizedBox(width: 8),
                BiDiHelper.buildMixedText(
                  text: title,
                  style: TextStyle(
                    fontSize: 16,
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
        return const Color(0xFF43A047);
      case 'متوسط':
        return const Color(0xFFFB8C00);
      case 'متقدم':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  void _copyToClipboard(BuildContext context, String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BiDiHelper.buildMixedText(
          text: successMessage,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0055FF),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
