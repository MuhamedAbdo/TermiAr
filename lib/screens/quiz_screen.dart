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
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  bool _showResult = false;
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
          _generateRandomQuiz();
          _isLoading = false;
        });
      } else {
        _createSampleQuestions();
      }
    } catch (e) {
      _createSampleQuestions();
    }
  }

  void _generateRandomQuiz() {
    final shuffledQuestions = List<QuizQuestion>.from(_allQuestions)..shuffle();
    _currentQuizQuestions = shuffledQuestions.take(10).toList();
    _currentQuestionIndex = 0;
    _score = 0;
    _isAnswered = false;
    _selectedAnswerIndex = null;
    _showResult = false;
  }

  void _createSampleQuestions() {
    final sampleQuestions = [
      QuizQuestion(
        id: 1,
        question_ar: 'ما هو الأمر المستخدم لعرض الملفات في المجلد الحالي؟',
        question_en: 'What command is used to list files in current directory?',
        options: ['ls', 'cd', 'mkdir', 'rm'],
        correct_answer_index: 0,
        explanation_ar: 'أمر ls يعرض قائمة بالملفات والمجلدات في المسار الحالي.',
        explanation_en: 'The ls command lists files and directories in current directory.',
      ),
      QuizQuestion(
        id: 2,
        question_ar: 'ما هو الأمر المستخدم لتغيير المجلد؟',
        question_en: 'What command is used to change directory?',
        options: ['ls', 'cd', 'pwd', 'mkdir'],
        correct_answer_index: 1,
        explanation_ar: 'أمر cd يستخدم للتنقل بين المجلدات المختلفة.',
        explanation_en: 'The cd command is used to navigate between directories.',
      ),
    ];

    setState(() {
      _allQuestions = sampleQuestions;
      _generateRandomQuiz();
      _isLoading = false;
    });
  }

  void _answerQuestion(int answerIndex) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = answerIndex;
      _isAnswered = true;
    });

    if (answerIndex == _currentQuizQuestions[_currentQuestionIndex].correct_answer_index) {
      setState(() {
        _score++;
      });
    }

    // Auto advance to next question after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
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
      setState(() {
        _showResult = true;
      });
    }
  }

  void _startNewQuiz() {
    _generateRandomQuiz();
  }

  void _goToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_allQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
        ),
        body: const Center(
          child: Text('No quiz questions available'),
        ),
      );
    }

    if (_showResult) {
      return _buildResultScreen();
    }

    final currentQuestion = _currentQuizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _currentQuizQuestions.length,
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0055FF)),
            ),
            const SizedBox(height: 16),
            
            // Question number
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_currentQuizQuestions.length}',
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Question
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: BiDiHelper.buildMixedText(
                  text: currentQuestion.question_ar,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  final isSelected = _selectedAnswerIndex == index;
                  final isCorrect = index == currentQuestion.correct_answer_index;
                  
                  Color backgroundColor;
                  Color borderColor;
                  Color textColor;
                  
                  if (!_isAnswered) {
                    backgroundColor = isSelected 
                        ? const Color(0xFF0055FF).withOpacity(0.1)
                        : Colors.transparent;
                    borderColor = isSelected 
                        ? const Color(0xFF0055FF)
                        : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!);
                    textColor = isDarkMode ? Colors.white : const Color(0xFF1A1A1A);
                  } else {
                    if (isCorrect) {
                      backgroundColor = Colors.green.withOpacity(0.1);
                      borderColor = Colors.green;
                      textColor = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      backgroundColor = Colors.red.withOpacity(0.1);
                      borderColor = Colors.red;
                      textColor = Colors.red;
                    } else {
                      backgroundColor = Colors.transparent;
                      borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
                      textColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
                    }
                  }
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: borderColor, width: 2),
                    ),
                    color: backgroundColor,
                    child: InkWell(
                      onTap: () => _answerQuestion(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: borderColor,
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: BiDiHelper.buildRichTextWithCommands(
                                text: option,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: textColor,
                                ),
                              ),
                            ),
                            if (_isAnswered && isCorrect)
                              const Icon(Icons.check_circle, color: Colors.green),
                            if (_isAnswered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Explanation (show after answering)
            if (_isAnswered) ...[
              const SizedBox(height: 16),
              Card(
                color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.blue[50],
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
                            'Explanation',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      BiDiHelper.buildRichTextWithCommands(
                        text: currentQuestion.explanation_ar,
                        style: GoogleFonts.cairo(
                          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final percentage = (_score / _currentQuizQuestions.length * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: percentage >= 70 
                    ? Colors.amber.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                percentage >= 70 ? Icons.emoji_events : Icons.star,
                size: 60,
                color: percentage >= 70 ? Colors.amber : Colors.blue,
              ),
            ),
            const SizedBox(height: 32),
            
            // Score Text
            Text(
              '$_score/${_currentQuizQuestions.length}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            
            // Percentage
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 24,
                color: percentage >= 70 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Performance Message
            BiDiHelper.buildMixedText(
              text: percentage >= 70 
                  ? 'Excellent work! 🎉'
                  : percentage >= 50
                      ? 'Good effort! Keep practicing! 💪'
                      : 'Keep learning! You\'ll get better! 📚',
              style: GoogleFonts.cairo(
                fontSize: 18,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startNewQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ابدأ اختباراً جديداً',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _goToHome,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0055FF),
                      side: const BorderSide(color: Color(0xFF0055FF)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
