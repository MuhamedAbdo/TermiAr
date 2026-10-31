import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../utils/bidi_helper.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _sendFeedback(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mohamedabdo9999933@gmail.com',
      query: _encodeQueryParameters(<String, String>{
        'subject': 'ملاحظات تطبيق TermiAr',
        'body': 'السلام عليكم،\n\nأود مشاركة الملاحظات التالية بخصوص تطبيق TermiAr:\n\n',
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
            content: Text('لم يتم العثور على تطبيق بريد إلكتروني على هذا الجهاز.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final themeBrightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('حول التطبيق'), centerTitle: true),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // الشعار واسم التطبيق
            Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0055FF).withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          themeBrightness == Brightness.dark
                              ? 'assets/images/logo_dark.png'
                              : 'assets/images/logo_light.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: themeBrightness == Brightness.dark
                                      ? [
                                          const Color(0xFF0055FF),
                                          const Color(0xFF003DCC),
                                        ]
                                      : [
                                          const Color(0xFF0055FF),
                                          const Color(0xFF3380FF),
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.terminal,
                                size: 50,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TermiAr',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  BiDiHelper.buildMixedText(
                    text: 'دليلك الشامل لأوامر لينكس',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0055FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'الإصدار 1.0.0',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0055FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // كارت نبذة عن التطبيق
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF0055FF)),
                        const SizedBox(width: 8),
                        Text(
                          'عن التطبيق',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BiDiHelper.buildMixedText(
                      text:
                          'تطبيق TermiAr هو مرجع تعليمي متكامل ومبسط لأوامر نظام لينكس بواجهة عربية، مصمم بهوية بصرية مستوحاة من نظام Zorin OS. يهدف التطبيق إلى مساعدة المبتدئين والمحترفين على فهم واحتراف أوامر الطرفية (Terminal) بسهولة وأمان وبدون الحاجة إلى اتصال بالإنترنت.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // كارت المميزات
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_outline, color: Color(0xFF0055FF)),
                        const SizedBox(width: 8),
                        Text(
                          'المميزات الرئيسية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureItem(
                      context,
                      Icons.search,
                      'بحث فوري وسريع',
                      'البحث في الأوامر والأسماء العربية والوصف بمرونة فائقة',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.category_outlined,
                      'تصنيفات شاملة',
                      'تنظيم الأوامر حسب التوزيعات (دبيان، ريد هات) والوظائف',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.content_copy,
                      'نسخ بنقرة واحدة',
                      'إمكانية نسخ أي أمر أو صيغة أو مثال مباشرة للحافظة',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.quiz_outlined,
                      'اختبارات تعليمية تفاعلية',
                      'تحديات معرفية مخصصة لاختبار مهاراتك في بيئات لينكس',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.lightbulb_outline,
                      'نصائح يومية متجددة',
                      'نصائح وحيل ذكية يومية لإتقان العمل على الطرفية',
                    ),
                    _buildFeatureItem(
                      context,
                      Icons.wifi_off,
                      'يعمل بدون إنترنت',
                      'جميع البيانات والأدوات متاحة بالكامل أوفلاين دون الحاجة لاتصال',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // كارت الملاحظات والتواصل
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.feedback_outlined, color: Color(0xFF0055FF)),
                        const SizedBox(width: 8),
                        Text(
                          'الملاحظات والاقتراحات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BiDiHelper.buildMixedText(
                      text:
                          'رأيك يهمنا في تطوير TermiAr! إذا كانت لديك اقتراحات لأوامر جديدة أو واجهت مشكلة، لا تتردد في مراسلتنا.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDarkMode
                            ? Colors.white70
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _sendFeedback(context),
                        icon: const Icon(Icons.email_outlined),
                        label: const Text(
                          'إرسال ملاحظة للمطور',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0055FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                '© 2026 TermiAr. جميع الحقوق محفوظة.',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0055FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0055FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
