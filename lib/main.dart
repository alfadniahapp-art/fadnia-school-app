import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/school_data.dart';
import 'models/settings.dart';
import 'models/attendance.dart';
import 'models/calendar_event.dart';
import 'models/fees.dart';
import 'models/defaults.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MullaApp());
}

class MullaApp extends StatelessWidget {
  const MullaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DefaultsProvider()),
        ChangeNotifierProvider(
            create: (_) => SchoolDataProvider()..loadData()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(
            create: (_) => AttendanceProvider()..load()),
        ChangeNotifierProvider(
            create: (_) => CalendarProvider()..load()),
        ChangeNotifierProvider(
            create: (_) => FeesProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          AppTheme.updateColors(
            primary: settings.primaryColor,
            background: settings.backgroundColor,
          );

          return MaterialApp(
            title: 'مدارس الفادنية شرق',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.buildTheme(
              primary: settings.primaryColor,
              background: settings.backgroundColor,
            ),
            locale: const Locale('ar'),
            builder: (context, child) => Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
