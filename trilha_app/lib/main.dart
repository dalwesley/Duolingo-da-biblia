import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/lesson_screen.dart';
import 'screens/splash_screen.dart';
import 'services/backend_service.dart';
import 'services/companion_service.dart';
import 'services/league_service.dart';
import 'services/home_widget_service.dart';
import 'services/notification_service.dart';
import 'services/progress_service.dart';
import 'services/room_service.dart';
import 'services/sound_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  await SoundService.instance.init();
  await NotificationService.instance.init();
  await HomeWidgetService.init();

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
        ChangeNotifierProvider(create: (_) => LeagueService()..init()),
        ChangeNotifierProvider(create: (_) => BackendService()..init()),
        ChangeNotifierProxyProvider<BackendService, RoomService>(
          create: (ctx) => RoomService(ctx.read<BackendService>())..init(),
          update: (_, backend, previous) {
            final room = previous ?? RoomService(backend);
            if (backend.isActive && !room.hasRoom) {
              room.syncIfNeeded();
            }
            return room;
          },
        ),
        ChangeNotifierProxyProvider<BackendService, CompanionService>(
          create: (ctx) => CompanionService(ctx.read<BackendService>())..init(),
          update: (_, backend, previous) {
            final companions = previous ?? CompanionService(backend);
            if (backend.isActive) {
              companions.refresh();
            }
            return companions;
          },
        ),
      ],
      child: Consumer<ProgressService>(
        builder: (context, progress, _) {
          SoundService.instance.setEnabled(progress.settings.sound);
          return MaterialApp(
            title: 'Trilha',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    progress.settings.fontScale.clamp(0.85, 1.35),
                  ),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
            onGenerateRoute: (settings) {
              if (settings.name == '/lesson') {
                final slug = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => LessonScreen(missionSlug: slug),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
