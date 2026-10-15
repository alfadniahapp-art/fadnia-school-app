import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/school_data.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import 'themes_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _developerName = "Abu Almulla";
  static const String _phoneDisplay = "+249 92 200 8009";
  static const String _phoneClean = "249922008009";
  static const String _appVersion = "6.1.0";

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SchoolDataProvider>();
    final settings = context.watch<SettingsProvider>();
    final primary = settings.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: settings.backgroundColor,
        title: Text("حول التطبيق",
            style: TextStyle(color: primary, fontFamily: 'Changa')),
        iconTheme: IconThemeData(color: primary),
      ),
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ============ الشعار ============
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.3),
                      primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.school, size: 60, color: primary),
              ),

              const SizedBox(height: 20),

              // ============ الاسم ============
              Text("Mulla",
                  style: TextStyle(
                      color: primary,
                      fontFamily: 'Changa',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 4),
              const Text("لإدارة المدارس",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Changa',
                      fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  border: Border.all(color: primary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("الإصدار $_appVersion",
                    style: TextStyle(
                        color: primary,
                        fontFamily: 'Changa',
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 20),

              // ============ بيانات المدرسة ============
              _infoCard(
                primary: primary,
                icon: Icons.school,
                title: "المدرسة",
                value: data.name,
                subtitle: "المرحلة ${data.stage} - ${data.type}",
              ),

              const SizedBox(height: 15),

              // ============ 🎨 زر الثيمات ============
              _actionCard(
                icon: Icons.palette,
                title: "الثيمات والألوان",
                subtitle: "تخصيص المظهر بشكل كامل",
                color: primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ThemesScreen()),
                ),
              ),

              const SizedBox(height: 20),

              // ============ المطور ============
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withOpacity(0.15),
                      AppColors.darkNavy,
                    ],
                  ),
                  border: Border.all(color: primary, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Text("تصميم وتطوير",
                            style: TextStyle(
                                color: primary,
                                fontFamily: 'Changa',
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: primary.withOpacity(0.2),
                          child: Icon(Icons.person,
                              color: primary, size: 30),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_developerName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Changa',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              const Text("مطوّر تطبيقات",
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'Changa',
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 10),

                    // 📞 رقم الهاتف — بإتجاه LTR
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone,
                              color: primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                _phoneDisplay,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Changa',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy,
                                color: primary, size: 20),
                            tooltip: "نسخ الرقم",
                            onPressed: () async {
                              await Clipboard.setData(
                                  const ClipboardData(
                                      text: _phoneDisplay));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text("تم نسخ الرقم"),
                                  backgroundColor: AppColors.green,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // أزرار التواصل
                    Row(
                      children: [
                        Expanded(
                          child: _contactButton(
                            icon: Icons.call,
                            label: "اتصال",
                            color: AppColors.green,
                            onTap: () => _launch(
                                context, "tel:$_phoneClean"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _contactButton(
                            icon: Icons.chat,
                            label: "واتساب",
                            color: const Color(0xFF25D366),
                            onTap: () {
                              final msg = Uri.encodeComponent(
                                  "السلام عليكم، أتواصل بخصوص تطبيق Mulla لإدارة المدارس");
                              _launch(context,
                                  "https://wa.me/$_phoneClean?text=$msg");
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ============ المزايا ============
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Text("مزايا التطبيق",
                            style: TextStyle(
                                color: primary,
                                fontFamily: 'Changa',
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _feature("📅 إدارة جدول الحصص"),
                    _feature("👨‍🏫 إدارة المعلمين والموظفين"),
                    _feature("👤 إدارة الطلاب وأولياء الأمور"),
                    _feature("💰 نظام رسوم متكامل"),
                    _feature("💵 رواتب وحوافز وسلف"),
                    _feature("🏦 خزينة وحسابات مالية"),
                    _feature("📊 تقارير PDF و Excel"),
                    _feature("🎨 تخصيص كامل للألوان والعملة"),
                    _feature("📱 واجهة عربية أنيقة"),
                    _feature("💾 نسخ احتياطي واستيراد"),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ============ الحقوق ============
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.copyright,
                        color: Colors.white38, size: 20),
                    const SizedBox(height: 6),
                    const Text("جميع الحقوق محفوظة",
                        style: TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa',
                            fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("© 2026 $_developerName",
                        style: TextStyle(
                            color: primary,
                            fontFamily: 'Changa',
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("رجوع",
                      style: TextStyle(fontFamily: 'Changa')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required Color primary,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Changa',
                        fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontFamily: 'Changa',
                        fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                AppColors.darkNavy,
              ],
            ),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: color,
                            fontFamily: 'Changa',
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Changa',
                            fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: AppColors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Changa',
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لا يمكن فتح الرابط"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
