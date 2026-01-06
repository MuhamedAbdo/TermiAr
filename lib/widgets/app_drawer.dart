import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/bidi_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showPrivacyPolicy(BuildContext context) {
    Navigator.pop(context);
    // Use rootBundle to load the privacy policy file
    rootBundle.loadString('assets/data/privacy_policy.md').then((content) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: BiDiHelper.buildMixedText(
                text: 'سياسة الخصوصية',
                style: GoogleFonts.cairo(
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
                style: GoogleFonts.cairo(fontSize: 14, height: 1.6),
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

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF1A1A1A).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
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
                borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Image.asset(
                    isDarkMode ? 'assets/images/logo_dark.png' : 'assets/images/logo_light.png',
                    width: 80, height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text('TermiAr', style: GoogleFonts.cairo(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text('Your Linux Command Companion', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14)),
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
                      title: isDarkMode ? 'الوضع الفاتح (Light Mode)' : 'الوضع المظلم (Dark Mode)',
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) { themeProvider.toggleTheme(); Navigator.pop(context); },
                        activeColor: const Color(0xFF0055FF),
                      ),
                      onTap: () { themeProvider.toggleTheme(); Navigator.pop(context); },
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(isDarkMode, Icons.person_outline, 'محمد عبد العال (Mohamed Abdelaal)'),
                            const SizedBox(height: 12),
                            _buildInfoRow(isDarkMode, Icons.phone_outlined, '+201148578813'),
                            _buildInfoRow(isDarkMode, Icons.email_outlined, 'mohamedabdo9999933@gmail.com'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods to fix the 'child' issues
  Widget _buildSectionHeader(bool isDarkMode, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: BiDiHelper.buildMixedText(
          text: title,
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black87),
        title: BiDiHelper.buildMixedText(
          text: title,
          style: GoogleFonts.cairo(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 14),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
      ),
    );
  }

  Widget _buildInfoRow(bool isDarkMode, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDarkMode ? Colors.blue : Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(child: BiDiHelper.buildMixedText(text: text, style: GoogleFonts.cairo(fontSize: 13, color: isDarkMode ? Colors.white : Colors.black87))),
      ],
    );
  }
}