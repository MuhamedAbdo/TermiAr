import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../utils/bidi_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHome;

  const QuizScreen({super.key, this.onNavigateToHome});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> _allQuestions = [];
  List<QuizQuestion> _currentQuizQuestions = [];
  List<QuizCategory> _categories = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  bool _showResult = false;
  bool _showCategorySelection = true;
  String? _selectedDistro;
  int? _selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final quizData = await DataService.loadQuizData();
      setState(() {
        _allQuestions = quizData.questions ?? [];
        _categories =
            quizData.quizInfo?.categories ??
            [
              QuizCategory(
                id: 'debian_family',
                name_ar: 'عائلة دبيان',
                name_en: 'Debian Family',
              ),
              QuizCategory(
                id: 'redhat_family',
                name_ar: 'عائلة ريد هات',
                name_en: 'Red Hat Family',
              ),
            ];
        _isLoading = false;
      });
    } catch (e) {
      _setDefaultData();
    }
  }

  void _setDefaultData() {
    setState(() {
      _categories = [
        QuizCategory(
          id: 'debian_family',
          name_ar: 'عائلة دبيان',
          name_en: 'Debian Family',
        ),
        QuizCategory(
          id: 'redhat_family',
          name_ar: 'عائلة ريد هات',
          name_en: 'Red Hat Family',
        ),
      ];
      _allQuestions = [];
      _isLoading = false;
    });
  }

  void _selectDistro(String distroId) {
    setState(() {
      _selectedDistro = distroId;
      _showCategorySelection = false;
      _generateQuiz();
    });
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

  void _generateQuiz() {
    final filtered = _allQuestions.where((q) {
      return q.distro == _selectedDistro || q.distro == 'common';
    }).toList();

    final shuffled = List<QuizQuestion>.from(filtered)..shuffle();
    setState(() {
      _currentQuizQuestions = shuffled.take(15).toList();
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _showResult = false;
    });
  }

  void _answerQuestion(int index) {
    if (_isAnswered) return;
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index ==
          _currentQuizQuestions[_currentQuestionIndex].correct_answer_index) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      setState(() => _showResult = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showCategorySelection) return _buildCategorySelection(isDarkMode);
    if (_showResult) return _buildResultScreen();

    if (_currentQuizQuestions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("لا توجد أسئلة كافية لهذا النظام حالياً"),
              ElevatedButton(
                onPressed: () => setState(() => _showCategorySelection = true),
                child: const Text("عودة"),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _currentQuizQuestions[_currentQuestionIndex];
    final categoryTheme = _getCategoryTheme(_selectedDistro!);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedDistro == 'debian_family'
              ? 'اختبار عائلة دبيان'
              : 'اختبار عائلة ريد هات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? categoryTheme['darkGradient']
                  : categoryTheme['lightGradient'],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
      body: Stack(
        children: [
          // Watermark background
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Center(
                child: Icon(
                  _selectedDistro == 'debian_family'
                      ? Icons.settings_suggest
                      : Icons.security,
                  size: 250,
                  color: _selectedDistro == 'debian_family'
                      ? const Color(0xFFD70A53)
                      : const Color(0xFFCC0000),
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Progress Bar
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor:
                          (_currentQuestionIndex + 1) /
                          _currentQuizQuestions.length,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: isDarkMode
                                ? categoryTheme['darkGradient']
                                : categoryTheme['lightGradient'],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Question Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white,
                      border: Border.all(
                        color: categoryTheme['borderColor']!.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: BiDiHelper.buildMixedText(
                        text: currentQuestion.question_ar,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Options
                  ...List.generate(currentQuestion.options.length, (index) {
                    return _buildOptionCard(index, currentQuestion, isDarkMode);
                  }),
                  if (_isAnswered)
                    _buildExplanation(currentQuestion, isDarkMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // تم إصلاح الدوال الفرعية وإضافة الأقواس الناقصة

  Widget _buildCategorySelection(bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختر نظامك',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF448AFF), const Color(0xFF2979FF)]
                  : [const Color(0xFF0055FF), const Color(0xFF003DCC)],
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _categories
              .map((cat) => _buildCategoryCard(cat, isDarkMode))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(QuizCategory category, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF448AFF), const Color(0xFF2979FF)]
              : [const Color(0xFF0055FF), const Color(0xFF003DCC)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _selectDistro(category.id),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Text(
                category.name_ar,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                category.name_en,
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, QuizQuestion q, bool isDarkMode) {
    bool isCorrect = index == q.correct_answer_index;
    bool isSelected = _selectedAnswerIndex == index;
    final categoryTheme = _getCategoryTheme(_selectedDistro!);

    Color backgroundColor;
    Color borderColor;

    if (!_isAnswered) {
      backgroundColor = isDarkMode
          ? Colors.white.withOpacity(0.05)
          : Colors.white;
      borderColor = isSelected
          ? categoryTheme['borderColor']
          : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!);
    } else {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
      } else {
        backgroundColor = isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white;
        borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
      }
    }

    return GestureDetector(
      onTap: () => _answerQuestion(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? borderColor : Colors.grey,
              radius: 15,
              child: Text(
                String.fromCharCode(65 + index),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: BiDiHelper.buildMixedText(
                text: q.options[index],
                style: GoogleFonts.cairo(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizQuestion q, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الشرح:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          BiDiHelper.buildMixedText(
            text: q.explanation_ar,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              'النتيجة: $_score / ${_currentQuizQuestions.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => setState(() => _showCategorySelection = true),
              child: const Text('إعادة الاختبار'),
            ),
            TextButton(
              onPressed: widget.onNavigateToHome,
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}
