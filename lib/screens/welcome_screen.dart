import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/school_data.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameCtrl = TextEditingController(text: "مدارس الفادنية شرق");
  String _stage = "المتوسطة";
  String _type = "بنين";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppColors.darkNavy.withOpacity(0.95),
                border: Border.all(color: AppColors.gold, width: 2),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.4),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Mulla",
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      fontFamily: 'Changa',
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "لإدارة المدارس",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Changa',
                    ),
                  ),
                  const SizedBox(height: 25),
                  const CustomLabel("اسم المدرسة:"),
                  TextField(
                    controller: _nameCtrl,
                    decoration:
                        const InputDecoration(hintText: "مثال: مدارس الفادنية"),
                  ),
                  const CustomLabel("المرحلة التعليمية:"),
                  DropdownButtonFormField<String>(
                    value: _stage,
                    dropdownColor: AppColors.darkNavy,
                    items: const [
                      DropdownMenuItem(
                          value: "الابتدائية", child: Text("الابتدائية")),
                      DropdownMenuItem(
                          value: "المتوسطة", child: Text("المتوسطة")),
                      DropdownMenuItem(
                          value: "الثانوية", child: Text("الثانوية")),
                    ],
                    onChanged: (v) => setState(() => _stage = v!),
                  ),
                  const CustomLabel("المسار / النوع:"),
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
                  const SizedBox(height: 20),
                  SuccessButton(
                    label: "دخول للنظام",
                    icon: Icons.login,
                    onTap: () async {
                      context.read<SchoolDataProvider>().setSchoolInfo(
                            n: _nameCtrl.text.trim().isEmpty
                                ? "مدارس الفادنية شرق"
                                : _nameCtrl.text.trim(),
                            s: _stage,
                            t: _type,
                          );
                      await AuthService.setLoggedIn(true);
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
