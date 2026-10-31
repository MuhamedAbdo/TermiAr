import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../services/quiz_progress_service.dart';
import '../utils/bidi_helper.dart';

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
  final Map<String, int> _categoryHighScores = {};
  Map<String, dynamic> _overallStats = {};

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  bool _showResult = false;
  bool _showCategorySelection = true;
  bool _isNewHighScore = false;
  String? _selectedDistro;
  int? _selectedAnswerIndex;

  // Track session answers for the review accordion
  final List<Map<String, dynamic>> _sessionReview = [];

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final quizData = await DataService.loadQuizData();
      final stats = await QuizProgressService.getOverallStats();

      final categories = quizData.quizInfo?.categories ?? [
        QuizCategory(id: 'universal', name_ar: 'أوامر اللينكس المشتركة', name_en: 'Universal Linux'),
        QuizCategory(id: 'debian_family', name_ar: 'عائلة دبيان وأوبنتو', name_en: 'Debian Family'),
        QuizCategory(id: 'redhat_family', name_ar: 'عائلة ريد هات وفيدورا', name_en: 'Red Hat Family'),
        QuizCategory(id: 'flutter_dart', name_ar: 'فلاتر ودارت', name_en: 'Flutter & Dart'),
        QuizCategory(id: 'android_dev', name_ar: 'تطوير أندرويد (ADB)', name_en: 'Android Development'),
        QuizCategory(id: 'git_github', name_ar: 'إدارة الإصدارات (Git)', name_en: 'Git & GitHub'),
      ];

      // Load high scores for each category
      final Map<String, int> highScores = {};
      for (final cat in categories) {
        highScores[cat.id] = await QuizProgressService.getHighScore(cat.id);
      }

      if (mounted) {
        setState(() {
          _allQuestions = quizData.questions ?? [];
          _categories = categories;
          _categoryHighScores.addAll(highScores);
          _overallStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectDistro(String distroId) {
    setState(() {
      _selectedDistro = distroId;
      _showCategorySelection = false;
      _generateQuiz();
    });
  }

  void _generateQuiz() {
    final filtered = _allQuestions.where((q) {
      if (_selectedDistro == 'universal') {
        return q.distro == 'universal' || q.distro == 'common';
      }
      return q.distro == _selectedDistro || q.distro == 'universal' || q.distro == 'common';
    }).toList();

    final shuffled = List<QuizQuestion>.from(filtered)..shuffle();
    final count = shuffled.length < 10 ? shuffled.length : 10;

    setState(() {
      _currentQuizQuestions = shuffled.take(count).toList();
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _showResult = false;
      _isNewHighScore = false;
      _sessionReview.clear();
    });
  }

  void _answerQuestion(int index) {
    if (_isAnswered) return;

    final currentQuestion = _currentQuizQuestions[_currentQuestionIndex];
    final isCorrect = index == currentQuestion.correct_answer_index;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (isCorrect) {
        _score++;
      }

      _sessionReview.add({
        'question': currentQuestion,
        'user_answer_index': index,
        'is_correct': isCorrect,
      });
    });
  }

  void _nextQuestion() async {
    if (_currentQuestionIndex < _currentQuizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      // Save quiz results offline
      final category = _categories.firstWhere(
        (c) => c.id == _selectedDistro,
        orElse: () => QuizCategory(id: _selectedDistro ?? '', name_ar: 'اختبار لينكس', name_en: 'Linux Quiz'),
      );

      final isNewHigh = await QuizProgressService.saveQuizResult(
        categoryId: _selectedDistro ?? 'universal',
        categoryNameAr: category.name_ar,
        score: _score,
        totalQuestions: _currentQuizQuestions.length,
      );

      final updatedHigh = await QuizProgressService.getHighScore(_selectedDistro ?? 'universal');
      final updatedStats = await QuizProgressService.getOverallStats();

      if (mounted) {
        setState(() {
          _isNewHighScore = isNewHigh;
          _categoryHighScores[_selectedDistro ?? 'universal'] = updatedHigh;
          _overallStats = updatedStats;
          _showResult = true;
        });
      }
    }
  }

  Map<String, dynamic> _getCategoryTheme(String categoryId) {
    switch (categoryId) {
      case 'debian_family':
        return {
          'lightGradient': [const Color(0xFFD70A53), const Color(0xFFA80030)],
          'darkGradient': [const Color(0xFFE5396B), const Color(0xFFC2185B)],
          'borderColor': const Color(0xFF8B0026),
          'shadowColor': const Color(0xFFD70A53).withValues(alpha: 0.3),
        };
      case 'redhat_family':
        return {
          'lightGradient': [const Color(0xFFCC0000), const Color(0xFF990000)],
          'darkGradient': [const Color(0xFFE53935), const Color(0xFFD32F2F)],
          'borderColor': const Color(0xFF990000),
          'shadowColor': const Color(0xFFCC0000).withValues(alpha: 0.3),
        };
      case 'flutter_dart':
        return {
          'lightGradient': [const Color(0xFF02569B), const Color(0xFF0175C2)],
          'darkGradient': [const Color(0xFF027DFD), const Color(0xFF01579B)],
          'borderColor': const Color(0xFF01579B),
          'shadowColor': const Color(0xFF02569B).withValues(alpha: 0.3),
        };
      case 'android_dev':
        return {
          'lightGradient': [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
          'darkGradient': [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
          'borderColor': const Color(0xFF1B5E20),
          'shadowColor': const Color(0xFF3DDC84).withValues(alpha: 0.3),
        };
      case 'git_github':
        return {
          'lightGradient': [const Color(0xFFF05032), const Color(0xFFC0392B)],
          'darkGradient': [const Color(0xFFFF6E40), const Color(0xFFF05032)],
          'borderColor': const Color(0xFFBF360C),
          'shadowColor': const Color(0xFFF05032).withValues(alpha: 0.3),
        };
      default:
        return {
          'lightGradient': [const Color(0xFF0055FF), const Color(0xFF003DCC)],
          'darkGradient': [const Color(0xFF448AFF), const Color(0xFF2979FF)],
          'borderColor': const Color(0xFF0029CC),
          'shadowColor': const Color(0xFF0055FF).withValues(alpha: 0.3),
        };
    }
  }

  Widget _buildCategoryWatermark(String categoryId, bool isDarkMode) {
    if (categoryId == 'debian_family') {
      return SvgPicture.asset(
        'assets/images/debian_watermark_official.svg',
        width: 250,
        height: 250,
      );
    } else if (categoryId == 'redhat_family') {
      return SvgPicture.asset(
        'assets/images/redhat_watermark_official.svg',
        width: 250,
        height: 250,
      );
    } else if (categoryId == 'flutter_dart') {
      return Opacity(
        opacity: isDarkMode ? 0.08 : 0.05,
        child: SvgPicture.asset('assets/images/flutter_official_logo.svg', width: 230, height: 230),
      );
    } else if (categoryId == 'android_dev') {
      return Opacity(
        opacity: isDarkMode ? 0.08 : 0.05,
        child: SvgPicture.asset('assets/images/android_official_logo.svg', width: 230, height: 230),
      );
    } else if (categoryId == 'git_github') {
      return Opacity(
        opacity: isDarkMode ? 0.08 : 0.05,
        child: SvgPicture.asset('assets/images/git_official_logo.svg', width: 230, height: 230),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _getCategoryIconWidget(String categoryId) {
    switch (categoryId) {
      case 'debian_family':
        return SvgPicture.asset('assets/images/debian_official_logo.svg', width: 34, height: 34);
      case 'redhat_family':
        return SvgPicture.asset('assets/images/redhat_official_logo.svg', width: 34, height: 34);
      case 'flutter_dart':
        return SvgPicture.asset('assets/images/flutter_official_logo.svg', width: 34, height: 34);
      case 'android_dev':
        return SvgPicture.asset('assets/images/android_official_logo.svg', width: 34, height: 34);
      case 'git_github':
        return SvgPicture.asset('assets/images/git_official_logo.svg', width: 34, height: 34);
      default:
        return const Icon(Icons.computer, color: Colors.white, size: 30);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showCategorySelection) return _buildCategorySelection(isDarkMode);
    if (_showResult) return _buildResultScreen(isDarkMode);

    if (_currentQuizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('الاختبار التفاعلي')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("لا توجد أسئلة كافية لهذا التصنيف حالياً", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => setState(() => _showCategorySelection = true),
                icon: const Icon(Icons.arrow_back),
                label: const Text("العودة لاختيار تصنيف آخر"),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getCategoryIconWidget(_selectedDistro!),
            const SizedBox(width: 8),
            Text(
              _categories.firstWhere((c) => c.id == _selectedDistro, orElse: () => _categories.first).name_ar,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amberAccent),
                const SizedBox(width: 4),
                Text(
                  '$_score / ${_currentQuestionIndex + (_isAnswered ? 1 : 0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: isDarkMode ? categoryTheme['darkGradient'] : categoryTheme['lightGradient'],
            ),
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          if (!_showCategorySelection) {
            setState(() => _showCategorySelection = true);
          } else {
            widget.onNavigateToHome?.call();
          }
        },
        child: Stack(
          children: [
            // Watermark background
            Positioned.fill(
              child: Center(
                child: _buildCategoryWatermark(_selectedDistro!, isDarkMode),
              ),
            ),
            // Main content
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Progress Indicator Bar
                        Row(
                          children: [
                            Text(
                              'السؤال ${_currentQuestionIndex + 1} من ${_currentQuizQuestions.length}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentQuestion.difficulty.isNotEmpty ? currentQuestion.difficulty : 'متوسط',
                                style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_currentQuestionIndex + 1) / _currentQuizQuestions.length,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  colors: isDarkMode ? categoryTheme['darkGradient'] : categoryTheme['lightGradient'],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Situational Question Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDarkMode ? const Color(0xFF242424) : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDarkMode ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0055FF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.help_outline, color: Color(0xFF0055FF), size: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'تحدي عملي (Situational Problem)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0055FF),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              BiDiHelper.buildMixedText(
                                text: currentQuestion.question_ar,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Options
                        ...List.generate(currentQuestion.options.length, (index) {
                          return _buildOptionCard(
                            index,
                            currentQuestion,
                            isDarkMode,
                          );
                        }),

                        // In-depth Educational Feedback
                        if (_isAnswered)
                          _buildEducationalFeedback(currentQuestion, isDarkMode),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection(bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أكاديمية الاختبارات والتعلم',
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          widget.onNavigateToHome?.call();
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall User Stats Dashboard Card
                  _buildStatsDashboard(isDarkMode),
                  const SizedBox(height: 24),

                  Text(
                    'اختر مجال التحدي والاختبار:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'تم تصميم الأسئلة على شكل مواقف وتحديات برمجية حقيقية لترسيخ الفهم مع شروحات تعليمية لكل خيار.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories List
                  ..._categories.map((cat) => _buildCategoryCard(cat, isDarkMode)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsDashboard(bool isDarkMode) {
    final attempts = _overallStats['total_attempts'] ?? 0;
    final totalCorrect = _overallStats['total_correct'] ?? 0;
    final totalQuestions = _overallStats['total_questions'] ?? 0;
    final accuracy = _overallStats['accuracy'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1E2638), const Color(0xFF141926)]
              : [const Color(0xFFEBF3FF), const Color(0xFFD6E6FF)],
        ),
        border: Border.all(
          color: const Color(0xFF0055FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Color(0xFF0055FF), size: 22),
              const SizedBox(width: 8),
              Text(
                'سجل تقدمك التعليمي (Offline Progress)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF003DCC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('الاختبارات المنجزة', '$attempts', Icons.check_circle_outline, Colors.blue),
              _buildStatItem('الإجابات الصحيحة', '$totalCorrect / $totalQuestions', Icons.done_all, Colors.green),
              _buildStatItem('نسبة الدقة', '$accuracy%', Icons.pie_chart_outline, Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(QuizCategory category, bool isDarkMode) {
    final theme = _getCategoryTheme(category.id);
    final highScore = _categoryHighScores[category.id] ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode ? theme['darkGradient'] : theme['lightGradient'],
        ),
        boxShadow: [
          BoxShadow(
            color: theme['shadowColor'],
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDistro(category.id),
          mouseCursor: SystemMouseCursors.click,
          hoverColor: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _getCategoryIconWidget(category.id),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name_ar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.name_en,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      if (highScore > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, size: 14, color: Colors.amberAccent),
                              const SizedBox(width: 4),
                              Text(
                                'أعلى نتيجة: $highScore / 10',
                                style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
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
    final categoryTheme = _getCategoryTheme(_selectedDistro!);

    Color backgroundColor;
    Color borderColor;
    Widget trailingIcon = const SizedBox.shrink();

    if (!_isAnswered) {
      backgroundColor = isDarkMode ? const Color(0xFF202020) : Colors.white;
      borderColor = isSelected ? categoryTheme['borderColor'] : (isDarkMode ? Colors.white12 : Colors.black12);
    } else {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: isDarkMode ? 0.2 : 0.1);
        borderColor = Colors.green;
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green, size: 22);
      } else if (isSelected) {
        backgroundColor = Colors.red.withValues(alpha: isDarkMode ? 0.2 : 0.1);
        borderColor = Colors.red;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red, size: 22);
      } else {
        backgroundColor = isDarkMode ? const Color(0xFF202020) : Colors.white;
        borderColor = isDarkMode ? Colors.white10 : Colors.black12;
      }
    }

    final letter = ['أ', 'ب', 'ج', 'د'][index < 4 ? index : 0];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isSelected || (isCorrect && _isAnswered) ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnswered ? null : () => _answerQuestion(index),
          mouseCursor: _isAnswered
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          hoverColor: const Color(0xFF0055FF).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCorrect && _isAnswered
                        ? Colors.green
                        : (isSelected && _isAnswered
                            ? Colors.red
                            : (isDarkMode ? Colors.white12 : Colors.grey[200])),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: (isSelected || isCorrect) && _isAnswered
                          ? Colors.white
                          : (isDarkMode ? Colors.white70 : Colors.black87),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: BiDiHelper.buildMixedText(
                    text: q.options[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                trailingIcon,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEducationalFeedback(QuizQuestion q, bool isDarkMode) {
    final isCorrect = _selectedAnswerIndex == q.correct_answer_index;

    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: isDarkMode ? 0.15 : 0.08)
            : Colors.amber.withValues(alpha: isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.amber.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.lightbulb,
                color: isCorrect ? Colors.green : Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'إجابة صحيحة وممتازة!' : 'الشرح والتحليل التعليمي:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? (isDarkMode ? Colors.greenAccent : Colors.green[800])
                      : (isDarkMode ? Colors.amberAccent : Colors.amber[900]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          BiDiHelper.buildMixedText(
            text: q.explanation_ar,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),

          // Option-by-option educational breakdown (if available)
          if (q.options_explanations_ar.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 6),
            const Text(
              'لماذا الخيارات الأخرى خاطئة أو ماذا تفعل؟',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(q.options_explanations_ar.length, (i) {
              final isThisOptionCorrect = i == q.correct_answer_index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isThisOptionCorrect ? Icons.check : Icons.close,
                      size: 16,
                      color: isThisOptionCorrect ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: BiDiHelper.buildMixedText(
                        text: q.options_explanations_ar[i],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _nextQuestion,
              icon: Icon(
                _currentQuestionIndex < _currentQuizQuestions.length - 1
                    ? Icons.arrow_forward
                    : Icons.emoji_events,
              ),
              label: Text(
                _currentQuestionIndex < _currentQuizQuestions.length - 1
                    ? 'السؤال التالي'
                    : 'عرض النتيجة النهائية',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0055FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(bool isDarkMode) {
    final percentage = ((_score / (_currentQuizQuestions.isEmpty ? 1 : _currentQuizQuestions.length)) * 100).round();

    Color scoreColor;
    String feedbackTitle;
    String feedbackMessage;

    if (percentage >= 80) {
      scoreColor = Colors.green;
      feedbackTitle = 'أداء أسطوري! 🏆';
      feedbackMessage = 'معرفتك بأوامر الطرفية والبيئة العملية ممتازة ومثيرة للإعجاب.';
    } else if (percentage >= 60) {
      scoreColor = Colors.blue;
      feedbackTitle = 'أداء رائع جداً! 👏';
      feedbackMessage = 'لديك فهم عملي ممتاز، وبقليل من الممارسة الإضافية ستصل للاحتراف الكامل.';
    } else if (percentage >= 40) {
      scoreColor = Colors.orange;
      feedbackTitle = 'بداية جيدة! 💡';
      feedbackMessage = 'أنت على الطريق الصحيح، راجع الشروحات أدناه لإتقان النقاط التي فاتت.';
    } else {
      scoreColor = Colors.redAccent;
      feedbackTitle = 'واصل التدريب! 🚀';
      feedbackMessage = 'كل خطأ هو فرصة للتعلم؛ اطلع على المراجعة التفصيلية بالأسفل ثم أعد المحاولة.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الاختبار'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
            if (_isNewHighScore)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'رقم قياسي جديد! تم تحديث أعلى نتيجة بنجاح',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                  ],
                ),
              ),

            // Score Circle
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.15),
                border: Border.all(color: scoreColor, width: 4),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_score / ${_currentQuizQuestions.length}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scoreColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              feedbackTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              feedbackMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generateQuiz,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة الاختبار'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _showCategorySelection = true),
                    icon: const Icon(Icons.category),
                    label: const Text('تصنيف آخر'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Detailed Review Section
            if (_sessionReview.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.rate_review_outlined, color: Color(0xFF0055FF)),
                  const SizedBox(width: 8),
                  const Text(
                    'مراجعة الأسئلة والشروحات (Review)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._sessionReview.map((item) {
                final QuizQuestion q = item['question'];
                final int userIndex = item['user_answer_index'];
                final bool isCorrect = item['is_correct'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isCorrect ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ExpansionTile(
                    leading: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      q.question_ar,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isCorrect) ...[
                              Text(
                                'إجابتك: ${q.options[userIndex]}',
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              'الإجابة الصحيحة: ${q.options[q.correct_answer_index]}',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              q.explanation_ar,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    ),
  ),
);
  }
}
