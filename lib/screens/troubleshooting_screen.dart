import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/troubleshooting_model.dart';
import '../providers/theme_provider.dart';
import '../services/data_service.dart';
import '../utils/bidi_helper.dart';

class TroubleshootingScreen extends StatefulWidget {
  const TroubleshootingScreen({super.key});

  @override
  State<TroubleshootingScreen> createState() => _TroubleshootingScreenState();
}

class _TroubleshootingScreenState extends State<TroubleshootingScreen> {
  bool _isLoading = true;
  List<TroubleshootingGuide> _allGuides = [];
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _guidesScrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadGuides();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _guidesScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadGuides() async {
    try {
      final response = await DataService.loadTroubleshootingGuides();
      if (mounted) {
        setState(() {
          _allGuides = response.guides;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allGuides = [];
          _isLoading = false;
        });
      }
    }
  }

  List<TroubleshootingGuide> get _filteredGuides {
    return _allGuides.where((guide) {
      // Category filter
      if (_selectedCategory != 'all' && guide.category != _selectedCategory) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final titleAr = guide.title_ar.toLowerCase();
        final titleEn = guide.title_en.toLowerCase();
        final desc = guide.description_ar.toLowerCase();
        final matchesDiagnosis = guide.diagnostic_steps.any((s) =>
            s.command.toLowerCase().contains(_searchQuery) ||
            s.title.toLowerCase().contains(_searchQuery));
        final matchesSolution = guide.solutions.any((s) =>
            s.command.toLowerCase().contains(_searchQuery) ||
            s.title.toLowerCase().contains(_searchQuery));

        return titleAr.contains(_searchQuery) ||
            titleEn.contains(_searchQuery) ||
            desc.contains(_searchQuery) ||
            matchesDiagnosis ||
            matchesSolution;
      }
      return true;
    }).toList();
  }

  IconData _getGuideIcon(String iconName) {
    switch (iconName) {
      case 'computer':
        return Icons.computer;
      case 'android':
        return Icons.android;
      case 'flutter':
        return Icons.flutter_dash;
      case 'storage':
        return Icons.storage;
      default:
        return Icons.build_circle_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'system':
        return const Color(0xFF0055FF);
      case 'android':
        return const Color(0xFF2E7D32);
      case 'flutter':
        return const Color(0xFF02569B);
      case 'hardware':
        return const Color(0xFF7B1FA2);
      default:
        return const Color(0xFF0055FF);
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'system':
        return 'إعداد النظام والصيانة';
      case 'android':
        return 'أندرويد و ADB';
      case 'flutter':
        return 'فلاتر ودارت';
      case 'hardware':
        return 'العتاد والتخزين';
      default:
        return 'عام';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'دليل حل المشكلات (Troubleshooting)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [const Color(0xFF0055FF), const Color(0xFF003DCC)]
                  : [const Color(0xFF0055FF), const Color(0xFF3380FF)],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  children: [
                    _buildSearchAndFilters(isDarkMode),
                    Expanded(
                      child: _filteredGuides.isEmpty
                          ? _buildEmptyState(isDarkMode)
                          : Scrollbar(
                              controller: _guidesScrollController,
                              interactive: true,
                              child: ListView.builder(
                                controller: _guidesScrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredGuides.length,
                                itemBuilder: (context, index) {
                                  return _buildGuideCard(
                                    _filteredGuides[index],
                                    isDarkMode,
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchAndFilters(bool isDarkMode) {
    final categories = [
      {'id': 'all', 'label': 'جميع الأدلة (${_allGuides.length})'},
      {'id': 'system', 'label': 'النظام والصيانة'},
      {'id': 'android', 'label': 'أندرويد و ADB'},
      {'id': 'flutter', 'label': 'فلاتر ودارت'},
      {'id': 'hardware', 'label': 'العتاد والتخزين'},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن مشكلة، خطأ، أو أمر تشخيصي...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              filled: true,
              fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    label: Text(cat['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat['id']!;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أدلة مطابقة للبحث',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCategory = 'all';
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إظهار جميع الأدلة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(TroubleshootingGuide guide, bool isDarkMode) {
    final categoryColor = _getCategoryColor(guide.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.white12 : Colors.black12,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openGuideDetails(guide),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      _getGuideIcon(guide.icon),
                      color: categoryColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.title_ar,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.title_en,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                guide.description_ar,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryDisplayName(guide.category),
                      style: TextStyle(
                        fontSize: 11,
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Diagnostics count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.manage_search, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${guide.diagnostic_steps.length} خطوات تشخيصية',
                          style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // Solutions count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${guide.solutions.length} حلول خطوة بخطوة',
                          style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGuideDetails(TroubleshootingGuide guide) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuideDetailsView(guide: guide),
      ),
    );
  }
}

class GuideDetailsView extends StatelessWidget {
  final TroubleshootingGuide guide;

  const GuideDetailsView({super.key, required this.guide});

  void _copyCommand(BuildContext context, String command, String label) {
    Clipboard.setData(ClipboardData(text: command));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ: $label'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0055FF),
      ),
    );
  }

  void _copyAllSolutions(BuildContext context) {
    final allCommands = guide.solutions.map((s) => s.command).join('\n');
    Clipboard.setData(ClipboardData(text: allCommands));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ جميع أوامر الحل إلى الحافظة بنجاح'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title_ar, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'نسخ جميع أوامر الحل',
            onPressed: () => _copyAllSolutions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Description Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF242424) : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF0055FF), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'وصف المشكلة ونطاق الدليل:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    guide.description_ar,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Diagnostic Section
            _buildSectionHeader(
              title: 'أولاً: خطوات التشخيص الآمنة (قراءة فقط)',
              icon: Icons.manage_search,
              color: Colors.blue,
              subtitle: 'استعلامات آمنة لقراءة حالة النظام دون إجراء أي تعديل للتعرف على أصل المشكلة بدقة.',
            ),
            const SizedBox(height: 12),
            ...guide.diagnostic_steps.map((step) => _buildStepItem(context, step, isDarkMode, isDiagnostic: true)),

            const SizedBox(height: 28),

            // Solutions Section
            _buildSectionHeader(
              title: 'ثانياً: خطوات الحل خطوة بخطوة',
              icon: Icons.build_circle,
              color: Colors.green,
              subtitle: 'نفذ هذه الأوامر بالتسلسل لحل المشكلة واستعادة استقرار النظام.',
            ),
            const SizedBox(height: 12),
            ...guide.solutions.map((step) => _buildStepItem(context, step, isDarkMode, isDiagnostic: false)),

            const SizedBox(height: 24),

            // Pro Tips Section
            if (guide.pro_tips.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: isDarkMode ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'نصائح وإرشادات الخبراء (Pro Tips):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...guide.pro_tips.map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber)),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 34.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    TroubleshootingStep step,
    bool isDarkMode, {
    required bool isDiagnostic,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.white12 : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDiagnostic ? Colors.blue : Colors.green).withValues(alpha: 0.15),
                ),
                child: Text(
                  '${step.step_number}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDiagnostic ? Colors.blue : Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 36.0),
            child: Text(
              step.description,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Code Terminal Box
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: BiDiHelper.buildMixedText(
                    text: step.command,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFF4FC3F7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                  tooltip: 'نسخ الأمر',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _copyCommand(context, step.command, step.title),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
