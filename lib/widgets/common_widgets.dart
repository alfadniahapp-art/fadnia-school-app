import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isExit;
  final double height;
  final IconData? icon;

  const NavButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isExit = false,
    this.height = 55,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              decoration: BoxDecoration(
                gradient: isExit
                    ? const LinearGradient(
                        colors: [Color(0xFF421212), Color(0xFF240808)],
                      )
                    : const LinearGradient(
                        colors: [AppColors.navy, AppColors.darkNavy],
                      ),
                border: Border.all(
                  color: isExit ? AppColors.red : AppColors.gold,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (isExit ? AppColors.red : AppColors.gold)
                        .withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon,
                          color:
                              isExit ? const Color(0xFFFF6B6B) : AppColors.gold,
                          size: 20),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isExit
                              ? const Color(0xFFFF6B6B)
                              : AppColors.gold,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Changa',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final IconData? icon;

  const SuccessButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppColors.green,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: color.withOpacity(0.15),
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                fontFamily: 'Changa',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomLabel extends StatelessWidget {
  final String text;
  const CustomLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(text, style: AppTheme.labelStyle),
      ),
    );
  }
}
