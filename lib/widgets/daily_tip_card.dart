import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../utils/bidi_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyTipCard extends StatefulWidget {
  const DailyTipCard({super.key});

  @override
  State<DailyTipCard> createState() => _DailyTipCardState();
}

class _DailyTipCardState extends State<DailyTipCard> {
  DailyTip? _dailyTip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyTip();
  }

  Future<void> _loadDailyTip() async {
    try {
      final quizData = await DataService.loadQuizData();
      if (quizData.daily_tips != null && quizData.daily_tips!.isNotEmpty) {
        final randomIndex = DateTime.now().day % quizData.daily_tips!.length;
        setState(() {
          _dailyTip = quizData.daily_tips![randomIndex];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_isLoading) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BiDiHelper.buildMixedText(
                    text: "نصيحة اليوم (Daily Tip)",
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // هنا نستخدم buildRichTextWithCommands في حال وجود أوامر داخل النصيحة
                  BiDiHelper.buildRichTextWithCommands(
                    text: _dailyTip?.tip_ar ?? "استخدم زر 'Tab' لإكمال الأوامر تلقائياً.",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}