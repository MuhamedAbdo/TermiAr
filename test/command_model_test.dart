import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:termi_ar/models/command_model.dart';
import 'package:termi_ar/providers/favorites_provider.dart';
import 'package:termi_ar/services/data_service.dart';
import 'package:termi_ar/services/quiz_progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('CommandModel & DataService Tests', () {
    test('CommandModel deserializes new attributes with defaults', () {
      final json = {
        'id': 100,
        'category_id': 'universal',
        'command': 'test_cmd',
        'syntax': 'test_cmd [options]',
        'level': 'مبتدئ',
        'name_ar': 'أمر تجريبي',
        'description': 'وصف تجريبي',
        'how_to_use': 'كيفية استخدام تجريبية',
        'can_copy': true,
      };

      final command = CommandModel.fromJson(json);

      expect(command.id, 100);
      expect(command.command, 'test_cmd');
      expect(command.risk_level, 'low');
      expect(command.warning, '');
      expect(command.distros, isEmpty);
      expect(command.options, isEmpty);
      expect(command.examples, isEmpty);
      expect(command.keywords, isEmpty);
      expect(command.expected_result, '');
      expect(command.common_errors, '');
    });

    test('CommandModel deserializes populated new attributes correctly', () {
      final json = {
        'id': 101,
        'category_id': 'file_management',
        'command': 'rm',
        'syntax': 'rm -rf [path]',
        'level': 'متقدم',
        'name_ar': 'حذف ملفات ومجلدات',
        'description': 'حذف نهائي',
        'how_to_use': 'كن حذراً',
        'can_copy': true,
        'risk_level': 'high',
        'warning': 'تحذير شديد',
        'distros': ['Ubuntu', 'Debian', 'Fedora'],
        'options': [
          {'flag': '-r', 'description': 'حذف متكرر'},
          {'flag': '-f', 'description': 'حذف إجباري'},
        ],
        'examples': [
          {'command': 'rm -rf dir/', 'description': 'حذف مجلد كامل'},
        ],
        'keywords': ['rm', 'delete', 'حذف'],
        'expected_result': 'تم الحذف بنجاح',
        'common_errors': 'Permission denied: استخدم sudo',
      };

      final command = CommandModel.fromJson(json);

      expect(command.id, 101);
      expect(command.risk_level, 'high');
      expect(command.warning, 'تحذير شديد');
      expect(command.distros, ['Ubuntu', 'Debian', 'Fedora']);
      expect(command.options.length, 2);
      expect(command.options.first.flag, '-r');
      expect(command.options.first.description, 'حذف متكرر');
      expect(command.examples.length, 1);
      expect(command.examples.first.command, 'rm -rf dir/');
      expect(command.keywords, ['rm', 'delete', 'حذف']);
      expect(command.expected_result, 'تم الحذف بنجاح');
      expect(command.common_errors, 'Permission denied: استخدم sudo');
    });

    test('DataService loads commands bank and caches results in memory', () async {
      DataService.clearCache();

      final firstLoad = await DataService.loadCommands();
      expect(firstLoad.commands.isNotEmpty, isTrue);

      final secondLoad = await DataService.loadCommands();
      expect(identical(firstLoad, secondLoad), isTrue);

      final lsCommand = firstLoad.commands.firstWhere((c) => c.id == 1);
      expect(lsCommand.command, 'ls');
      expect(lsCommand.risk_level, 'low');
      expect(lsCommand.options.isNotEmpty, isTrue);
      expect(lsCommand.examples.isNotEmpty, isTrue);
      expect(lsCommand.distros.isNotEmpty, isTrue);

      final rmCommand = firstLoad.commands.firstWhere((c) => c.id == 14);
      expect(rmCommand.command, 'rm');
      expect(rmCommand.risk_level, 'high');
      expect(rmCommand.warning.isNotEmpty, isTrue);
    });

    test('DataService.normalizeText handles Arabic spelling variations & diacritics', () {
      // Tashkeel / Harakat removal
      expect(DataService.normalizeText('تَحْدِيثٌ'), 'تحديث');
      // Alif variations (أ, إ, آ, ٱ -> ا)
      expect(DataService.normalizeText('إنشاء'), 'انشاء');
      expect(DataService.normalizeText('أوامر'), 'اوامر');
      // Taa Marbuta (ة -> ه)
      expect(DataService.normalizeText('ترقية'), 'ترقيه');
      // Yaa / Alif Maqsura (ى -> ي)
      expect(DataService.normalizeText('على'), 'علي');
      // Case insensitivity
      expect(DataService.normalizeText('  UBUNTU  '), 'ubuntu');
    });

    test('DataService.searchCommands searches across keywords, options, and examples', () async {
      DataService.clearCache();

      // Search by keyword in Arabic (with or without spelling variation)
      final keywordResults = await DataService.searchCommands('تحديث');
      expect(keywordResults.any((c) => c.id == 2), isTrue);

      // Search by option flag
      final optionResults = await DataService.searchCommands('-nogpgcheck');
      expect(optionResults.any((c) => c.command == 'dnf install'), isTrue);

      // Search by example command
      final exampleResults = await DataService.searchCommands('nginx');
      expect(exampleResults.any((c) => c.command == 'dnf install'), isTrue);

      // Search by normalized Arabic query (without hamza: 'انشاء' matches 'إنشاء')
      final hamzaResults = await DataService.searchCommands('انشاء');
      expect(hamzaResults.any((c) => c.command == 'mkdir'), isTrue);
    });

    test('DataService.searchCommands filters correctly by category, distro, and level', () async {
      DataService.clearCache();

      // Filter by category
      final debianResults = await DataService.searchCommands(
        '',
        categoryId: 'debian_family',
      );
      expect(debianResults.every((c) => c.category_id == 'debian_family'), isTrue);

      // Filter by difficulty level
      final advancedResults = await DataService.searchCommands(
        '',
        level: 'متقدم',
      );
      expect(advancedResults.every((c) => c.level == 'متقدم'), isTrue);

      // Filter by distro
      final fedoraResults = await DataService.searchCommands(
        '',
        distro: 'fedora',
      );
      expect(fedoraResults.any((c) => c.command == 'dnf install'), isTrue);

      // Combined query and filter
      final combinedResults = await DataService.searchCommands(
        'ls',
        level: 'مبتدئ',
      );
      expect(combinedResults.any((c) => c.command == 'ls'), isTrue);
    });

    test('DataService loads categories and includes new developer categories', () async {
      final response = await DataService.loadCategories();
      final categories = response.categories;
      expect(categories.isNotEmpty, isTrue);

      final catIds = categories.map((c) => c.id).toSet();
      expect(catIds.contains('flutter_dart'), isTrue);
      expect(catIds.contains('android_dev'), isTrue);
      expect(catIds.contains('git_github'), isTrue);

      final flutterCat = categories.firstWhere((c) => c.id == 'flutter_dart');
      expect(flutterCat.name_ar, 'فلاتر ودارت');
      expect(flutterCat.icon, 'flutter');

      final androidCat = categories.firstWhere((c) => c.id == 'android_dev');
      expect(androidCat.name_ar, 'تطوير أندرويد (ADB)');
      expect(androidCat.icon, 'android');

      final gitCat = categories.firstWhere((c) => c.id == 'git_github');
      expect(gitCat.name_ar, 'إدارة الإصدارات (Git)');
      expect(gitCat.icon, 'git');
    });

    test('New categories contain rich practical commands with expected_result & common_errors', () async {
      DataService.clearCache();
      final commandsResponse = await DataService.loadCommands();
      final commands = commandsResponse.commands;

      // Flutter commands
      final flutterCmds = commands.where((c) => c.category_id == 'flutter_dart').toList();
      expect(flutterCmds.length, greaterThanOrEqualTo(6));
      expect(flutterCmds.any((c) => c.command == 'flutter doctor -v'), isTrue);
      expect(flutterCmds.any((c) => c.command == 'flutter clean'), isTrue);
      expect(flutterCmds.any((c) => c.command == 'flutter run'), isTrue);
      expect(flutterCmds.every((c) => c.expected_result.isNotEmpty), isTrue);
      expect(flutterCmds.every((c) => c.common_errors.isNotEmpty), isTrue);

      // Android commands
      final androidCmds = commands.where((c) => c.category_id == 'android_dev').toList();
      expect(androidCmds.length, greaterThanOrEqualTo(6));
      expect(androidCmds.any((c) => c.command == 'adb devices'), isTrue);
      expect(androidCmds.any((c) => c.command == 'adb logcat'), isTrue);
      expect(androidCmds.every((c) => c.expected_result.isNotEmpty), isTrue);
      expect(androidCmds.every((c) => c.common_errors.isNotEmpty), isTrue);

      // Git commands
      final gitCmds = commands.where((c) => c.category_id == 'git_github').toList();
      expect(gitCmds.length, greaterThanOrEqualTo(7));
      expect(gitCmds.any((c) => c.command == 'git status'), isTrue);
      expect(gitCmds.any((c) => c.command == 'git push'), isTrue);
      
      // High-risk command verification
      final gitReset = gitCmds.firstWhere((c) => c.command == 'git reset --hard');
      expect(gitReset.risk_level, 'high');
      expect(gitReset.warning.contains('تحذير أمني شديد'), isTrue);
    });

    test('Search finds newly added developer commands by keywords and options', () async {
      DataService.clearCache();

      // Search Flutter by Arabic keyword
      final flutterSearch = await DataService.searchCommands('فحص');
      expect(flutterSearch.any((c) => c.command == 'flutter doctor -v'), isTrue);

      // Search Android by command
      final adbSearch = await DataService.searchCommands('logcat');
      expect(adbSearch.any((c) => c.command == 'adb logcat'), isTrue);

      // Search Git by option
      final gitSearch = await DataService.searchCommands('--oneline');
      expect(gitSearch.any((c) => c.command == 'git log --oneline'), isTrue);
    });

    test('FavoritesProvider manages custom tags and backward-compatible metadata', () async {
      final provider = FavoritesProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      // Toggle favorite with a custom tag
      await provider.toggleFavorite(349, tag: 'فلاتر');
      expect(provider.isFavorite(349), isTrue);
      expect(provider.getCommandTag(349), 'فلاتر');
      expect(provider.getAvailableTags().contains('فلاتر'), isTrue);
      expect(provider.getCommandAddedDate(349), greaterThan(0));

      // Update tag
      await provider.setCommandTag(349, 'أدوات');
      expect(provider.getCommandTag(349), 'أدوات');
      expect(provider.getAvailableTags().contains('أدوات'), isTrue);

      // Remove tag
      await provider.setCommandTag(349, null);
      expect(provider.getCommandTag(349), isNull);

      // Remove favorite
      await provider.toggleFavorite(349);
      expect(provider.isFavorite(349), isFalse);
    });

    test('QuizProgressService tracks high scores and calculates accuracy offline', () async {
      await QuizProgressService.clearHistory();

      // Save first result
      final isNewHigh1 = await QuizProgressService.saveQuizResult(
        categoryId: 'flutter_dart',
        categoryNameAr: 'فلاتر ودارت',
        score: 8,
        totalQuestions: 10,
      );
      expect(isNewHigh1, isTrue);

      final highScore1 = await QuizProgressService.getHighScore('flutter_dart');
      expect(highScore1, 8);

      // Save lower result (not high score)
      final isNewHigh2 = await QuizProgressService.saveQuizResult(
        categoryId: 'flutter_dart',
        categoryNameAr: 'فلاتر ودارت',
        score: 6,
        totalQuestions: 10,
      );
      expect(isNewHigh2, isFalse);

      final stats = await QuizProgressService.getOverallStats();
      expect(stats['total_attempts'], 2);
      expect(stats['total_questions'], 20);
      expect(stats['total_correct'], 14);
      expect(stats['accuracy'], 70); // (14 / 20) * 100 = 70%

      final history = await QuizProgressService.getRecentHistory();
      expect(history.length, 2);
      expect(history.first['score'], 6);
    });

    test('LearningQuiz loads situational questions and multi-option explanations', () async {
      DataService.clearCache();
      final quizData = await DataService.loadQuizData();

      expect(quizData.questions, isNotNull);
      expect(quizData.questions!.isNotEmpty, isTrue);

      // Validate all categories have questions
      final distros = quizData.questions!.map((q) => q.distro).toSet();
      expect(distros.contains('universal'), isTrue);
      expect(distros.contains('debian_family'), isTrue);
      expect(distros.contains('redhat_family'), isTrue);
      expect(distros.contains('flutter_dart'), isTrue);
      expect(distros.contains('android_dev'), isTrue);
      expect(distros.contains('git_github'), isTrue);

      // Verify situational nature and options explanations
      final sampleQ = quizData.questions!.firstWhere((q) => q.id == 1);
      expect(sampleQ.question_ar.contains('أنت تعمل على خادم لينكس'), isTrue);
      expect(sampleQ.options.length, 4);
      expect(sampleQ.options_explanations_ar.length, 4);
      expect(sampleQ.explanation_ar.isNotEmpty, isTrue);
    });
  });
}
