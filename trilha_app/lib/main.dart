import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/lesson_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'services/progress_service.dart';
import 'services/sound_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';
import 'utils/appearance.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await SoundService.instance.init();
  await NotificationService.instance.init();

  runApp(const TrilhaApp());
}

class TrilhaApp extends StatelessWidget {
  const TrilhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressService()..load()),
        ChangeNotifierProvider(create: (_) => SyncService()..init()),
      ],
      child: Consumer<ProgressService>(
        builder: (context, progress, _) {
          final dark = progress.settings.appearanceMode == AppearanceMode.night ||
              (progress.settings.appearanceMode == AppearanceMode.automatic &&
                  AppearanceStyle.resolve(AppearanceMode.automatic).onDark);
          SoundService.instance.setEnabled(progress.settings.sound);
          return MaterialApp(
            title: 'Trilha',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/lesson') {
                final slug = settings.arguments as String;
                return MaterialPageRoute(builder: (_) => LessonScreen(missionSlug: slug));
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
