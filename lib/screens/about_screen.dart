import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // المكتبة المطلوبة
import '../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // دالة إرسال البريد الإلكتروني
  Future<void> _sendFeedback(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mohamedabdo9999933@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'TermiAr App Feedback',
        'body': 'Hello Mohamed,\n\nI am writing to you regarding the TermiAr app...'
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app found on this device.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // دالة مساعدة لتشفير الروابط
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo and name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0055FF), Color(0xFF003DCC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0055FF).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.terminal, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TermiAr',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Linux Command Companion',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Color(0xFF0055FF)),
                        const SizedBox(width: 8),
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'TermiAr is a comprehensive, bilingual (Arabic/English) guide for Linux commands, specifically tailored with a Zorin OS aesthetic. The app targets beginners and power users alike, providing an intuitive interface to learn and master Linux terminal commands.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Features Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFF0055FF)),
                        const SizedBox(width: 8),
                        Text(
                          'Features',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(context, Icons.search, 'Real-time Search', 'Find any command instantly'),
                    _buildFeatureItem(context, Icons.category, 'Organized Categories', 'Commands grouped by functionality'),
                    _buildFeatureItem(context, Icons.content_copy, 'Copy to Clipboard', 'Quick copy any command'),
                    _buildFeatureItem(context, Icons.quiz, 'Interactive Quiz', 'Test your knowledge'),
                    _buildFeatureItem(context, Icons.lightbulb, 'Daily Tips', 'Learn new tricks daily'),
                    _buildFeatureItem(context, Icons.dark_mode, 'Dark Mode', 'Comfortable viewing experience'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Developer Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code, color: Color(0xFF0055FF)),
                        const SizedBox(width: 8),
                        Text(
                          'Developer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Built with Flutter for cross-platform compatibility.', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A))),
                    const SizedBox(height: 8),
                    Text('Open source and community driven.', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Feedback Card - المحدث
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.feedback, color: Color(0xFF0055FF)),
                        const SizedBox(width: 8),
                        Text(
                          'Feedback',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We value your feedback! Help us improve TermiAr by reporting bugs, suggesting features, or sharing your experience.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _sendFeedback(context), // الآن يعمل فعلياً
                        icon: const Icon(Icons.email),
                        label: const Text('Send Feedback'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0055FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(child: Text('© 2024 TermiAr. All rights reserved.', style: TextStyle(fontSize: 14, color: Colors.grey[500]))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String description) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF0055FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF0055FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A))),
                Text(description, style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}