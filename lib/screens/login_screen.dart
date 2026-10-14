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
                  const Icon(Icons.lock_outline,
                      color: AppColors.gold, size: 60),
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
                          fontSize: 14, letterSpacing: 0, color: Colors.white54),
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
                            color: Colors.redAccent, fontFamily: 'Changa')),
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
                        setState(() => _error = "كلمة المرور غير صحيحة");
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text("كلمة المرور الافتراضية: 1234",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                          fontFamily: 'Changa')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
