import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/bidi_helper.dart';
import 'package:flutter/services.dart';
import '../screens/troubleshooting_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.pop(context);
    rootBundle.loadString('assets/data/privacy_policy.md').then((content) {
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              centerTitle: true, // لتوحيد التصميم مع باقي الصفحات
              title: BiDiHelper.buildMixedText(
                text: 'سياسة الخصوصية',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final themeBrightness = Theme.of(context).brightness;

    return Drawer(
      // تم إزالة الشفافية من هنا لضمان عدم تداخل النصوص مع الصفحة الخلفية
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF0055FF), const Color(0xFF003DCC)]
                    : [const Color(0xFF0055FF), const Color(0xFF3380FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: ClipOval(
                    key: ValueKey(themeBrightness),
                    child: Image.asset(
                      themeBrightness == Brightness.dark
                          ? 'assets/images/logo_dark.png'
                          : 'assets/images/logo_light.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to terminal icon if image not found
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                          child: const Icon(
                            Icons.terminal,
                            size: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'TermiAr',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'دليلك الشامل لأوامر لينكس',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Settings
                  _buildSectionHeader(isDarkMode, 'الإعدادات (Settings)'),
                  _buildDrawerTile(
                    isDarkMode: isDarkMode,
                    icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    title: isDarkMode
                        ? 'الوضع الفاتح (Light Mode)'
                        : 'الوضع المظلم (Dark Mode)',
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                        Navigator.pop(context);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF0055FF),
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                      Navigator.pop(context);
                    },
                  ),

                  // Tools & Help
                  _buildSectionHeader(isDarkMode, 'المساعدة والأدوات (Tools)'),
                  _buildDrawerTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.build_circle_outlined,
                    title: 'دليل حل المشكلات (Troubleshooting)',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TroubleshootingScreen(),
                        ),
                      );
                    },
                  ),

                  // Legal
                  _buildSectionHeader(isDarkMode, 'قانوني (Legal)'),
                  _buildDrawerTile(
                    isDarkMode: isDarkMode,
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية (Privacy Policy)',
                    onTap: () => _showPrivacyPolicy(context),
                  ),

                  // Developer Info
                  _buildSectionHeader(isDarkMode, 'عن المطور (Developer)'),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            isDarkMode,
                            Icons.person_outline,
                            'محمد عبد العال',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            isDarkMode,
                            Icons.phone_outlined,
                            '+201148578813',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            isDarkMode,
                            Icons.email_outlined,
                            'mohamedabdo9999933@gmail.com',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // نسخة التطبيق في الأسفل
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'الإصدار 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isDarkMode, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0055FF), // لون مميز للعناوين الجانبية
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required bool isDarkMode,
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.01),
      ),
    );
  }

  Widget _buildInfoRow(bool isDarkMode, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0055FF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
