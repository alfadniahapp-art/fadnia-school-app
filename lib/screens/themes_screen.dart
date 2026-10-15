import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

/// ثيم جاهز
class PresetTheme {
  final String name;
  final String emoji;
  final int primary;
  final int background;

  const PresetTheme({
    required this.name,
    required this.emoji,
    required this.primary,
    required this.background,
  });
}

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  static const List<PresetTheme> _presets = [
    PresetTheme(
        name: 'ليلي ذهبي',
        emoji: '🌙',
        primary: 0xFFF1C40F,
        background: 0xFF0B132B),
    PresetTheme(
        name: 'أزرق عصري',
        emoji: '🌊',
        primary: 0xFF3498DB,
        background: 0xFF030817),
    PresetTheme(
        name: 'أخضر طبيعي',
        emoji: '🌿',
        primary: 0xFF27AE60,
        background: 0xFF0B1E14),
    PresetTheme(
        name: 'ناري أحمر',
        emoji: '🔥',
        primary: 0xFFE74C3C,
        background: 0xFF1C0C0C),
    PresetTheme(
        name: 'وردي أنثوي',
        emoji: '🌸',
        primary: 0xFFE91E63,
        background: 0xFF1C0C18),
    PresetTheme(
        name: 'بنفسجي فضائي',
        emoji: '🌌',
        primary: 0xFF9B59B6,
        background: 0xFF1A0B2E),
    PresetTheme(
        name: 'برتقالي دافئ',
        emoji: '🌅',
        primary: 0xFFF39C12,
        background: 0xFF2C1810),
    PresetTheme(
        name: 'فيروزي هادئ',
        emoji: '💎',
        primary: 0xFF1ABC9C,
        background: 0xFF0A1F1B),
  ];

  static const List<int> _primaryColors = [
    0xFFF1C40F, // ذهبي
    0xFF3498DB, // أزرق
    0xFF27AE60, // أخضر
    0xFFE74C3C, // أحمر
    0xFF9B59B6, // بنفسجي
    0xFFF39C12, // برتقالي
    0xFF1ABC9C, // فيروزي
    0xFFE91E63, // وردي
    0xFF95A5A6, // رمادي
    0xFFFF5722, // برتقالي محروق
    0xFF00BCD4, // سماوي
    0xFF8BC34A, // أخضر فاتح
  ];

  static const List<int> _bgColors = [
    0xFF0B132B, // كحلي داكن
    0xFF030817, // أسود أزرق
    0xFF000000, // أسود خالص
    0xFF1C1C1C, // رمادي داكن
    0xFF2C1810, // بني داكن
    0xFF1A0B2E, // بنفسجي داكن
    0xFF0B1E14, // أخضر داكن
    0xFF1C0C0C, // أحمر داكن
  ];

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final primary = s.primaryColor;
    final bg = s.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        title: Text("الثيمات والألوان",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color.lerp(bg, primary, 0.15) ?? bg,
              bg,
            ],
            center: Alignment.center,
            radius: 1.2,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============ المعاينة الحية ============
              _livePreview(s, primary, bg),
              const SizedBox(height: 20),

              // ============ الثيمات الجاهزة ============
              _sectionTitle("🎭 ثيمات جاهزة", primary),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _presets.length,
                itemBuilder: (_, i) {
                  final p = _presets[i];
                  final selected = s.primaryColorValue == p.primary &&
                      s.backgroundColorValue == p.background;
                  return _presetCard(context, s, p, selected);
                },
              ),
              const SizedBox(height: 25),

              // ============ اللون الأساسي ============
              _sectionTitle("🎨 اللون الأساسي", primary),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _primaryColors
                    .map((c) => _colorCircle(context, s, c))
                    .toList(),
              ),
              const SizedBox(height: 25),

              // ============ لون الخلفية ============
              _sectionTitle("🌈 لون الخلفية", primary),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _bgColors
                    .map((c) => _bgSquare(context, s, c))
                    .toList(),
              ),

              const SizedBox(height: 30),

              // ============ معلومات ============
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: primary.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: primary, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "التغييرات تُحفظ تلقائياً وتُطبّق على التطبيق كاملاً",
                        style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Changa',
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============ إعادة التعيين ============
              SuccessButton(
                label: "🔄 إعادة التعيين للافتراضي",
                icon: Icons.refresh,
                color: AppColors.orange,
                onTap: () => _confirmReset(context, s),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _livePreview(
      SettingsProvider s, Color primary, Color bg) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.2),
            bg,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: primary, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: primary, size: 20),
              const SizedBox(width: 8),
              Text("معاينة مباشرة",
                  style: TextStyle(
                      color: primary,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Icon(Icons.visibility, color: primary, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          // بطاقة معاينة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primary.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text("مثال على البطاقة",
                        style: TextStyle(
                            color: primary,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 6,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("زر",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Changa',
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        border: Border.all(color: primary),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text("ثانوي",
                          style: TextStyle(
                              color: primary,
                              fontFamily: 'Changa',
                              fontWeight: FontWeight.bold,
                              fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, Color primary) {
    return Text(title,
        style: TextStyle(
            color: primary,
            fontFamily: 'Changa',
            fontSize: 15,
            fontWeight: FontWeight.bold));
  }

  Widget _presetCard(BuildContext context, SettingsProvider s,
      PresetTheme p, bool selected) {
    final pc = Color(p.primary);
    final bc = Color(p.background);

    return GestureDetector(
      onTap: () {
        s.setPrimaryColor(p.primary);
        s.setBackgroundColor(p.background);
        _snack(context, "تم تطبيق ثيم: ${p.name}");
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bc, Color.lerp(bc, pc, 0.3) ?? bc],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(
            color: selected ? pc : Colors.white24,
            width: selected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p.emoji, style: const TextStyle(fontSize: 24)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: TextStyle(
                            color: pc,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: pc,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white30, width: 1),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: bc,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white30, width: 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (selected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: pc,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.black, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _colorCircle(
      BuildContext context, SettingsProvider s, int colorValue) {
    final c = Color(colorValue);
    final selected = s.primaryColorValue == colorValue;
    return GestureDetector(
      onTap: () {
        s.setPrimaryColor(colorValue);
        _snack(context, "تم تغيير اللون الأساسي");
      },
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: selected ? 4 : 0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: c.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 2)
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 26)
            : null,
      ),
    );
  }

  Widget _bgSquare(
      BuildContext context, SettingsProvider s, int colorValue) {
    final c = Color(colorValue);
    final selected = s.backgroundColorValue == colorValue;
    return GestureDetector(
      onTap: () {
        s.setBackgroundColor(colorValue);
        _snack(context, "تم تغيير لون الخلفية");
      },
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? s.primaryColor : Colors.white24,
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: s.primaryColor.withOpacity(0.5),
                      blurRadius: 12)
                ]
              : null,
        ),
        child: selected
            ? Icon(Icons.check, color: s.primaryColor, size: 24)
            : null,
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.green,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _confirmReset(BuildContext context, SettingsProvider s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkNavy,
        title: const Text("إعادة التعيين",
            style: TextStyle(
                color: Colors.orange, fontFamily: 'Changa')),
        content: const Text(
            "سيتم إرجاع الألوان للوضع الافتراضي (ذهبي + كحلي).\n\nهل أنت متأكد؟",
            style: TextStyle(
                color: Colors.white, fontFamily: 'Changa')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              s.setPrimaryColor(0xFFF1C40F);
              s.setBackgroundColor(0xFF0B132B);
              Navigator.pop(context);
              _snack(context, "تمت إعادة التعيين");
            },
            child: const Text("تعيين",
                style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}
