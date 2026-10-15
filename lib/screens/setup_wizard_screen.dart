import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});
  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _nameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: "1446 هـ");
  final _semCtrl = TextEditingController(text: "الفصل الأول");
  final _currencyCtrl = TextEditingController(text: "ج.س");

  String _template = "متوسطة";
  String _stage = "المتوسطة";
  String _type = "بنين";
  int _primaryColor = 0xFFF1C40F;
  int _bgColor = 0xFF0B132B;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              // شريط التقدم
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: List.generate(
                    4,
                    (i) => Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: i <= _page
                              ? Color(_primaryColor)
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // الصفحات
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _welcomePage(),
                    _schoolPage(),
                    _stylePage(),
                    _summaryPage(),
                  ],
                ),
              ),
              // أزرار التنقل
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    if (_page > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _pageCtrl.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(_primaryColor)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text("السابق",
                              style: TextStyle(
                                  color: Color(_primaryColor),
                                  fontFamily: 'Changa')),
                        ),
                      ),
                    if (_page > 0) const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SuccessButton(
                        label: _page == 3 ? "🎉 ابدأ الاستخدام" : "التالي",
                        icon: _page == 3
                            ? Icons.check_circle
                            : Icons.arrow_forward,
                        onTap: () {
                          if (_page == 3) {
                            _finish(context);
                          } else {
                            _pageCtrl.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        },
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

  // ============ صفحة 1: الترحيب ============
  Widget _welcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Icon(Icons.school, size: 100, color: Color(_primaryColor)),
          const SizedBox(height: 20),
          Text("مرحباً بك في Mulla",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(_primaryColor),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Changa')),
          const SizedBox(height: 10),
          const Text("سنساعدك على إعداد التطبيق في دقيقة واحدة",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Changa')),
          const SizedBox(height: 40),
          const Text("🏫 ما حجم مدرستك؟",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _templateCard("صغيرة", "🏠", "أقل من 10 معلمين",
              "جدول، معلمون، طلاب، درجات"),
          _templateCard("متوسطة", "🏫", "10-30 معلم",
              "كل الصغيرة + رسوم، أولياء أمور، غياب"),
          _templateCard("كبيرة", "🏛️", "أكثر من 30 معلم",
              "كل شيء + إحصائيات، تقارير متقدمة"),
        ],
      ),
    );
  }

  Widget _templateCard(
      String key, String emoji, String subtitle, String desc) {
    final selected = _template == key;
    return GestureDetector(
      onTap: () => setState(() => _template = key),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? Color(_primaryColor).withOpacity(0.15)
              : AppColors.darkNavy,
          border: Border.all(
            color: selected ? Color(_primaryColor) : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(key,
                      style: TextStyle(
                          color: selected
                              ? Color(_primaryColor)
                              : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Changa')),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Changa')),
                  Text(desc,
                      style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontFamily: 'Changa')),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: Color(_primaryColor), size: 30),
          ],
        ),
      ),
    );
  }

  // ============ صفحة 2: بيانات المدرسة ============
  Widget _schoolPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text("🏫 بيانات المدرسة",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const CustomLabel("اسم المدرسة:"),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                hintText: "مثال: مدارس الفادنية شرق"),
          ),
          const CustomLabel("المرحلة التعليمية:"),
          DropdownButtonFormField<String>(
            value: _stage,
            dropdownColor: AppColors.darkNavy,
            items: const [
              DropdownMenuItem(value: "الابتدائية", child: Text("الابتدائية")),
              DropdownMenuItem(value: "المتوسطة", child: Text("المتوسطة")),
              DropdownMenuItem(value: "الثانوية", child: Text("الثانوية")),
            ],
            onChanged: (v) => setState(() => _stage = v!),
          ),
          const CustomLabel("النوع:"),
          DropdownButtonFormField<String>(
            value: _type,
            dropdownColor: AppColors.darkNavy,
            items: const [
              DropdownMenuItem(value: "بنين", child: Text("بنين")),
              DropdownMenuItem(value: "بنات", child: Text("بنات")),
              DropdownMenuItem(value: "مختلط", child: Text("مختلط")),
            ],
            onChanged: (v) => setState(() => _type = v!),
          ),
          const CustomLabel("العام الدراسي:"),
          TextField(controller: _yearCtrl),
          const CustomLabel("الفصل الدراسي:"),
          TextField(controller: _semCtrl),
        ],
      ),
    );
  }

  // ============ صفحة 3: التخصيص ============
  Widget _stylePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text("🎨 تخصيص المظهر",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const CustomLabel("اللون الأساسي:"),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _colorCircle(0xFFF1C40F),
              _colorCircle(0xFF3498DB),
              _colorCircle(0xFF27AE60),
              _colorCircle(0xFFE74C3C),
              _colorCircle(0xFF9B59B6),
              _colorCircle(0xFFF39C12),
              _colorCircle(0xFF1ABC9C),
            ],
          ),
          const SizedBox(height: 25),
          const CustomLabel("لون الخلفية:"),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _bgCircle(0xFF0B132B),
              _bgCircle(0xFF030817),
              _bgCircle(0xFF1C1C1C),
              _bgCircle(0xFF2C1810),
            ],
          ),
          const SizedBox(height: 25),
          const CustomLabel("العملة:"),
          TextField(
            controller: _currencyCtrl,
            decoration: const InputDecoration(hintText: "ج.س"),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['ج.س', 'ر.س', 'ج.م', '\$', 'د.إ']
                .map((c) => ChoiceChip(
                      label: Text(c,
                          style: TextStyle(
                              color: _currencyCtrl.text == c
                                  ? AppColors.darkest
                                  : Color(_primaryColor),
                              fontFamily: 'Changa')),
                      selected: _currencyCtrl.text == c,
                      selectedColor: Color(_primaryColor),
                      backgroundColor: AppColors.navy,
                      onSelected: (_) =>
                          setState(() => _currencyCtrl.text = c),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _colorCircle(int v) {
    final selected = _primaryColor == v;
    return GestureDetector(
      onTap: () => setState(() => _primaryColor = v),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Color(v),
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 4,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 26)
            : null,
      ),
    );
  }

  Widget _bgCircle(int v) {
    final selected = _bgColor == v;
    return GestureDetector(
      onTap: () => setState(() => _bgColor = v),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Color(v),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Color(_primaryColor) : Colors.white24,
            width: selected ? 3 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check, color: Color(_primaryColor), size: 26)
            : null,
      ),
    );
  }

  // ============ صفحة 4: الملخص ============
  Widget _summaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text("✅ ملخص الإعدادات",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _summaryRow("اسم المدرسة",
              _nameCtrl.text.isEmpty ? "—" : _nameCtrl.text),
          _summaryRow("المرحلة", _stage),
          _summaryRow("النوع", _type),
          _summaryRow("حجم المدرسة", _template),
          _summaryRow("العام الدراسي", _yearCtrl.text),
          _summaryRow("الفصل الدراسي", _semCtrl.text),
          _summaryRow("العملة", _currencyCtrl.text),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(_primaryColor).withOpacity(0.1),
              border: Border.all(color: Color(_primaryColor)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Color(_primaryColor)),
                const SizedBox(height: 8),
                const Text(
                  "يمكنك تغيير كل هذه الإعدادات لاحقاً من شاشة الإعدادات",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Changa',
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 14)),
          ),
          Text(value,
              style: TextStyle(
                  color: Color(_primaryColor),
                  fontFamily: 'Changa',
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }

  // ============ إنهاء ============
  void _finish(BuildContext context) async {
    final data = context.read<SchoolDataProvider>();
    final settings = context.read<SettingsProvider>();

    await data.setSchoolInfo(
      n: _nameCtrl.text.trim().isEmpty
          ? "مدرستي"
          : _nameCtrl.text.trim(),
      s: _stage,
      t: _type,
    );
    settings.setYear(_yearCtrl.text);
    settings.setSemester(_semCtrl.text);
    settings.setCurrency(_currencyCtrl.text.trim().isEmpty
        ? 'ج.س'
        : _currencyCtrl.text.trim());
    settings.setPrimaryColor(_primaryColor);
    settings.setBackgroundColor(_bgColor);
    settings.setTemplate(_template);

    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
