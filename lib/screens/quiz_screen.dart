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
                id: 'debian_zorin',
                name_ar: 'أوبنتو / زورين',
                name_en: 'Ubuntu / Zorin',
              ),
              QuizCategory(
                id: 'fedora_redhat',
                name_ar: 'فيدورا / ريد هات',
                name_en: 'Fedora / RHEL',
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
          id: 'debian_zorin',
          name_ar: 'أوبنتو / زورين',
          name_en: 'Ubuntu / Zorin',
        ),
        QuizCategory(
          id: 'fedora_redhat',
          name_ar: 'فيدورا / ريد هات',
          name_en: 'Fedora / RHEL',
        ),
      ];
      _allQuestions = []; // سيتم ملؤها من الـ Sample إذا لزم الأمر
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

  void _generateQuiz() {
    // تصفية صارمة: الأسئلة التي تطابق النظام المختار أو العامة فقط
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

    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_showCategorySelection) return _buildCategorySelection(isDarkMode);
    if (_showResult) return _buildResultScreen();

    // منع الخطأ في حال كانت القائمة فارغة بعد التصفية
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedDistro == 'debian_zorin' ? 'اختبار أوبنتو' : 'اختبار فيدورا',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF448AFF), const Color(0xFF2979FF)]
                  : [const Color(0xFF0055FF), const Color(0xFF003DCC)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Modern Gradient Progress Bar
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
                            ? [const Color(0xFF448AFF), const Color(0xFF2979FF)]
                            : [
                                const Color(0xFF0055FF),
                                const Color(0xFF003DCC),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Glassmorphism Question Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
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
              // عرض الخيارات
              ...List.generate(currentQuestion.options.length, (index) {
                return _buildOptionCard(index, currentQuestion, isDarkMode);
              }),
              if (_isAnswered) _buildExplanation(currentQuestion, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection(bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختر نظامك',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF448AFF), const Color(0xFF2979FF)]
                  : [const Color(0xFF0055FF), const Color(0xFF003DCC)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _categories
                  .map((cat) => _buildCategoryCard(cat, isDarkMode))
                  .toList(),
            ),
          ),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF448AFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDistro(category.id),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      isDarkMode
                          ? 'assets/images/logo_dark.png'
                          : 'assets/images/logo_light.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  category.name_ar,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  category.name_en,
                  style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, QuizQuestion q, bool isDarkMode) {
    bool isCorrect = index == q.correct_answer_index;
    bool isSelected = _selectedAnswerIndex == index;

    // Dynamic colors for feedback
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (!_isAnswered) {
      backgroundColor = isDarkMode
          ? Colors.white.withOpacity(0.05)
          : Colors.white.withOpacity(0.7);
      borderColor = isSelected
          ? (isDarkMode ? const Color(0xFF448AFF) : const Color(0xFF0055FF))
          : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!);
      textColor = isDarkMode ? Colors.white70 : Colors.black87;
    } else {
      if (isCorrect) {
        backgroundColor = isDarkMode
            ? Colors.green.withOpacity(0.2)
            : Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green.shade700;
      } else if (isSelected) {
        backgroundColor = isDarkMode
            ? Colors.red.withOpacity(0.2)
            : Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red.shade700;
      } else {
        backgroundColor = isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7);
        borderColor = isDarkMode ? Colors.grey[600]! : Colors.grey[300]!;
        textColor = isDarkMode ? Colors.white70 : Colors.black87;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _answerQuestion(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Modern Option Letter Circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isSelected
                          ? (isDarkMode
                                ? [
                                    const Color(0xFF448AFF),
                                    const Color(0xFF2979FF),
                                  ]
                                : [
                                    const Color(0xFF0055FF),
                                    const Color(0xFF003DCC),
                                  ])
                          : [borderColor, borderColor],
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: borderColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Option Text
                Expanded(
                  child: BiDiHelper.buildMixedText(
                    text: q.options[index],
                    style: GoogleFonts.cairo(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplanation(QuizQuestion q, bool isDarkMode) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.1)]
              : [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
        ),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'الشرح:',
                  style: GoogleFonts.cairo(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BiDiHelper.buildMixedText(
              text: q.explanation_ar,
              style: GoogleFonts.cairo(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                : [Colors.grey[50]!, Colors.grey[100]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy with glow effect
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              // Score Card with Glassmorphism
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.8),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'النتيجة',
                      style: GoogleFonts.cairo(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_score / ${_currentQuizQuestions.length}',
                      style: GoogleFonts.cairo(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        background: Paint()
                          ..shader = LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Modern Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  const Color(0xFF448AFF),
                                  const Color(0xFF2979FF),
                                ]
                              : [
                                  const Color(0xFF0055FF),
                                  const Color(0xFF003DCC),
                                ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isDarkMode
                                        ? const Color(0xFF448AFF)
                                        : const Color(0xFF0055FF))
                                    .withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              setState(() => _showCategorySelection = true),
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'إعادة الاختبار',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.8),
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Use callback to navigate home
                            if (widget.onNavigateToHome != null) {
                              widget.onNavigateToHome!();
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'العودة للرئيسية',
                              style: GoogleFonts.cairo(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
