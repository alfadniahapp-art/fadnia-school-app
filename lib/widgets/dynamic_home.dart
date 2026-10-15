import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

/// واجهة ديناميكية تعرض الأزرار حسب الوحدات المفعّلة
class DynamicHome extends StatelessWidget {
  final Map<String, Widget Function(BuildContext)> screens;
  final Map<String, String> labels;
  final Map<String, IconData> icons;

  const DynamicHome({
    super.key,
    required this.screens,
    required this.labels,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final enabled = settings.enabledModules.entries
        .where((e) => e.value && screens.containsKey(e.key))
        .map((e) => e.key)
        .toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: _buildRows(context, enabled),
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context, List<String> keys) {
    final rows = <Widget>[];
    for (int i = 0; i < keys.length; i += 2) {
      final first = keys[i];
      final second = i + 1 < keys.length ? keys[i + 1] : null;

      rows.add(Row(
        children: [
          _button(context, first),
          if (second != null) ...[
            const SizedBox(width: 12),
            _button(context, second),
          ] else
            const Spacer(),
        ],
      ));
      rows.add(const SizedBox(height: 12));
    }
    return rows;
  }

  Widget _button(BuildContext context, String key) {
    return NavButton(
      label: labels[key] ?? key,
      icon: icons[key],
      onTap: () {
        final builder = screens[key];
        if (builder != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: builder),
          );
        }
      },
    );
  }
}

/// بطاقة عرض إحصائية بسيطة
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontFamily: 'Changa',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontFamily: 'Changa',
            ),
          ),
        ],
      ),
    );
  }
}

/// عنوان قسم
class SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;

  const SectionTitle(this.title, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(
            color: color ?? AppColors.gold,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Changa',
          ),
        ),
      ),
    );
  }
}

/// زر دائري للأيقونات السريعة
class CircleAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const CircleAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (color ?? AppColors.gold).withOpacity(0.15),
              border:
                  Border.all(color: color ?? AppColors.gold, width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: color ?? AppColors.gold, size: 24),
          ),
        ),
      ),
    );
  }
}

/// صف معلومة (Label : Value)
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Changa',
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontFamily: 'Changa',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// زر مربع كبير للاستخدامات العامة
class BigButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const BigButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.gold;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                c.withOpacity(0.15),
                AppColors.darkNavy,
              ],
            ),
            border: Border.all(color: c, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: c, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: c,
                    fontFamily: 'Changa',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
