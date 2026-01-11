import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../utils/bidi_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

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
  bool _showCategorySelection = true; // التحكم في ظهور شاشة الاختيار
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
      if (quizData.questions != null && quizData.questions!.isNotEmpty) {
        setState(() {
          _allQuestions = quizData.questions!;
          _categories = quizData.quizInfo?.categories ?? [];

          // إذا كانت الفئات فارغة في JSON، نضع فئات افتراضية
          if (_categories.isEmpty) {
            _setDefaultCategories();
          }
          _isLoading = false;
        });
      } else {
        _createSampleQuestions();
      }
    } catch (e) {
      _createSampleQuestions();
    }
  }

  void _setDefaultCategories() {
    _categories = [
      QuizCategory(
        id: 'debian_zorin',
        name_ar: 'عائلة أوبنتو وزورين',
        name_en: 'Ubuntu & Zorin Family',
      ),
      QuizCategory(
        id: 'fedora_redhat',
        name_ar: 'عائلة فيدورا وريد هات',
        name_en: 'Fedora & RedHat Family',
      ),
    ];
  }

  void _createSampleQuestions() {
    final sampleQuestions = [
      QuizQuestion(
        id: 1,
        question_ar: 'ما هو الأمر المستخدم لعرض الملفات في المجلد الحالي؟',
        question_en: 'What command is used to list files in current directory?',
        options: ['ls', 'cd', 'mkdir', 'rm'],
        correct_answer_index: 0,
        explanation_ar:
            'أمر ls يعرض قائمة بالملفات والمجلدات في المسار الحالي.',
        explanation_en:
            'The ls command lists files and directories in current directory.',
        distro: 'common',
      ),
    ];

    setState(() {
      _allQuestions = sampleQuestions;
      _setDefaultCategories();
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
    // تصفية الأسئلة بناءً على النظام المختار أو الأسئلة العامة
    final filtered = _allQuestions
        .where((q) => q.distro == _selectedDistro || q.distro == 'common')
        .toList();

    final shuffled = List<QuizQuestion>.from(filtered)..shuffle();

    setState(() {
      _currentQuizQuestions = shuffled.take(10).toList();
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswerIndex = null;
      _showResult = false;
    });
  }

  void _answerQuestion(int answerIndex) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = answerIndex;
      _isAnswered = true;
      if (answerIndex ==
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

    // عرض شاشة اختيار النظام أولاً
    if (_showCategorySelection) {
      return _buildCategorySelection(isDarkMode);
    }

    if (_showResult) {
      return _buildResultScreen();
    }

    if (_currentQuizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('لا توجد أسئلة لهذا النظام حالياً')),
      );
    }

    final currentQuestion = _currentQuizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedDistro == 'debian_zorin'
              ? 'Ubuntu/Zorin Quiz'
              : 'Fedora/RHEL Quiz',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _currentQuizQuestions.length,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BiDiHelper.buildMixedText(
                  text: currentQuestion.question_ar,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(currentQuestion.options.length, (index) {
              return _buildOptionCard(index, currentQuestion, isDarkMode);
            }),
            if (_isAnswered) _buildExplanation(currentQuestion, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection(bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر نظامك'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _categories
                .map((cat) => _buildDistroCard(cat, isDarkMode))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDistroCard(QuizCategory cat, bool isDarkMode) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _selectDistro(cat.id),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Color(0xFF0055FF), Color(0xFF003DCC)],
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.terminal, color: Colors.white, size: 40),
              const SizedBox(height: 10),
              Text(
                cat.name_ar, // تأكد من مطابقة اسم الحقل في الموديل
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                cat.name_en,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(int index, QuizQuestion q, bool isDarkMode) {
    bool isSelected = _selectedAnswerIndex == index;
    bool isCorrect = index == q.correct_answer_index;

    Color borderColor = Colors.grey.withOpacity(0.3);
    if (_isAnswered) {
      if (isCorrect)
        borderColor = Colors.green;
      else if (isSelected)
        borderColor = Colors.red;
    } else if (isSelected) {
      borderColor = const Color(0xFF0055FF);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => _answerQuestion(index),
        leading: CircleAvatar(
          backgroundColor: borderColor,
          child: Text(
            String.fromCharCode(65 + index),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: BiDiHelper.buildMixedText(text: q.options[index]),
      ),
    );
  }

  Widget _buildExplanation(QuizQuestion q, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        color: Colors.blue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'الشرح:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              BiDiHelper.buildMixedText(text: q.explanation_ar),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
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
              child: const Text('إعادة الاختبار (تغيير النظام)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    );
  }
}
