import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  String? _error;

  // 🔓 عدّاد الضغطات على أيقونة القفل
  int _lockTapCount = 0;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundDecoration,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: AppColors.darkNavy.withOpacity(0.95),
                border: Border.all(color: AppColors.gold, width: 2),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 25),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔒 أيقونة القفل — اضغط 7 مرات
                  GestureDetector(
                    onTap: _onLockTap,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(
                            _lockTapCount > 0
                                ? 0.05 * _lockTapCount
                                : 0),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        color: AppColors.gold,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("تسجيل الدخول",
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Changa')),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,
                        letterSpacing: 8,
                        fontFamily: 'Changa'),
                    decoration: InputDecoration(
                      hintText: "أدخل كلمة المرور",
                      hintStyle: const TextStyle(
                          fontSize: 14,
                          letterSpacing: 0,
                          color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPass
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.gold,
                        ),
                        onPressed: () =>
                            setState(() => _showPass = !_showPass),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontFamily: 'Changa')),
                  ],
                  const SizedBox(height: 20),
                  SuccessButton(
                    label: "دخول",
                    icon: Icons.login,
                    onTap: () async {
                      if (_passCtrl.text == settings.password) {
                        await AuthService.setLoggedIn(true);
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const HomeScreen()),
                        );
                      } else {
                        setState(
                            () => _error = "كلمة المرور غير صحيحة");
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text("كلمة المرور الافتراضية: 1234",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontFamily: 'Changa')),
                  // 💡 تلميح صغير
                  const SizedBox(height: 8),
                  Text(
                    _lockTapCount > 0
                        ? "🔓 اضغط ${7 - _lockTapCount} مرات أخرى"
                        : "",
                    style: TextStyle(
                        color: _lockTapCount > 0
                            ? AppColors.orange
                            : Colors.transparent,
                        fontSize: 11,
                        fontFamily: 'Changa',
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  🔓 7 ضغطات على أيقونة القفل → إعادة تعيين
  // ============================================================
  void _onLockTap() {
    final now = DateTime.now();
    // إعادة العدّ إذا مرّ أكثر من 3 ثوانٍ بين الضغطات
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inSeconds > 3) {
      _lockTapCount = 0;
    }
    _lastTapTime = now;
    _lockTapCount++;

    setState(() {});

    if (_lockTapCount >= 7) {
      _lockTapCount = 0;
      _showResetDialog();
    }
  }

  // ============================================================
  //  🔐 نافذة إعادة تعيين كلمة المرور
  // ============================================================
  void _showResetDialog() {
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;
    bool showPass1 = false;
    bool showPass2 = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: AppColors.darkNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: AppColors.gold, width: 2),
          ),
          title: Column(
            children: [
              Icon(Icons.lock_reset,
                  color: AppColors.orange, size: 40),
              const SizedBox(height: 8),
              const Text("🔓 إعادة تعيين كلمة المرور",
                  style: TextStyle(
                      color: AppColors.gold,
                      fontFamily: 'Changa',
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              const Text("(الحل عند نسيان كلمة المرور)",
                  style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'Changa',
                      fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "هذه الميزة للحالات الطارئة فقط\nلا تطلب كلمة المرور القديمة",
                          style: TextStyle(
                              color: Colors.orange,
                              fontFamily: 'Changa',
                              fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                const Text("🔑 كلمة المرور الجديدة:",
                    style: TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Changa',
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: newPassCtrl,
                  obscureText: !showPass1,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 20,
                      letterSpacing: 4,
                      fontFamily: 'Changa'),
                  decoration: InputDecoration(
                    hintText: "4 أرقام على الأقل",
                    hintStyle: const TextStyle(
                        fontSize: 13, letterSpacing: 0),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPass1
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      onPressed: () =>
                          setD(() => showPass1 = !showPass1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text("🔁 تأكيد كلمة المرور:",
                    style: TextStyle(
                        color: AppColors.gold,
                        fontFamily: 'Changa',
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmCtrl,
                  obscureText: !showPass2,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 20,
                      letterSpacing: 4,
                      fontFamily: 'Changa'),
                  decoration: InputDecoration(
                    hintText: "أعد كتابة كلمة المرور",
                    hintStyle: const TextStyle(
                        fontSize: 13, letterSpacing: 0),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPass2
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.gold,
                        size: 20,
                      ),
                      onPressed: () =>
                          setD(() => showPass2 = !showPass2),
                    ),
                  ),
                ),

                if (error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      border: Border.all(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(error!,
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontFamily: 'Changa',
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء",
                  style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'Changa')),
            ),
            ElevatedButton(
              onPressed: () {
                final p1 = newPassCtrl.text.trim();
                final p2 = confirmCtrl.text.trim();

                if (p1.isEmpty || p2.isEmpty) {
                  setD(() => error = "املأ جميع الحقول");
                  return;
                }
                if (p1.length < 4) {
                  setD(() =>
                      error = "كلمة المرور يجب أن تكون 4 أرقام على الأقل");
                  return;
                }
                if (p1 != p2) {
                  setD(() => error = "كلمتا المرور غير متطابقتين");
                  return;
                }

                // ✅ حفظ كلمة المرور الجديدة
                context.read<SettingsProvider>().setPassword(p1);
                Navigator.pop(ctx);

                // 🎉 إشعار نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.white),
                        SizedBox(width: 8),
                        Text("تم تعيين كلمة المرور بنجاح ✓",
                            style: TextStyle(fontFamily: 'Changa')),
                      ],
                    ),
                    backgroundColor: AppColors.green,
                    duration: Duration(seconds: 3),
                  ),
                );

                // مسح حقل الدخول
                _passCtrl.clear();
                setState(() => _error = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
              child: const Text("✅ تعيين",
                  style: TextStyle(
                      color: AppColors.darkest,
                      fontFamily: 'Changa',
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
