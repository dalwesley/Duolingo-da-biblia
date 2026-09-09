import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/lesson_screen.dart';
import 'screens/splash_screen.dart';
import 'services/backend_service.dart';
import 'services/companion_service.dart';
import 'services/content_catalog_service.dart';
import 'services/league_service.dart';
import 'services/home_widget_service.dart';
import 'services/invite_deep_link_service.dart';
import 'services/notification_service.dart';
import 'services/progress_service.dart';
import 'services/remote_config_service.dart';
import 'services/room_service.dart';
import 'services/sound_service.dart';
import 'services/subscription_service.dart';
import 'services/sync_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (_) {}

  runApp(const TrilhaApp());

  // Não bloqueia o 1º frame (splash). Som, avisos e widget podem subir atrás.
  unawaited(SoundService.instance.init());
  unawaited(NotificationService.instance.init());
  unawaited(HomeWidgetService.init());
  unawaited(InviteDeepLinkService.instance.init());
  unawaited(ContentCatalogService.instance.ensureLoaded());
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
        ChangeNotifierProxyProvider<BackendService, SubscriptionService>(
          create: (_) => SubscriptionService()..init(),
          update: (_, backend, previous) {
            final sub = previous ?? SubscriptionService();
            unawaited(sub.bindUid(backend.uid));
            return sub;
          },
        ),
        ChangeNotifierProvider.value(value: RemoteConfigService.instance),
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
        ChangeNotifierProxyProvider2<BackendService, SubscriptionService,
            CompanionService>(
          create: (ctx) => CompanionService(
            ctx.read<BackendService>(),
            ctx.read<SubscriptionService>(),
          )..init(),
          update: (_, backend, subscription, previous) {
            final companions =
                previous ?? CompanionService(backend, subscription);
            // Só refresca quando a sessão fica ativa (não a cada saveNow).
            if (backend.isActive && !companions.cloudSynced) {
              companions.refresh();
            }
            if (!backend.isActive) {
              companions.markCloudUnsynced();
            }
            return companions;
          },
        ),
      ],
      child: Consumer<ProgressService>(
        builder: (context, progress, _) {
          SoundService.instance.setEnabled(progress.settings.sound);
          return MaterialApp(
            title: 'STWAY',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.dark,
            builder: (context, child) {
              // Fundo estável atrás das rotas — evita flash do window nativo.
              return ColoredBox(
                color: AppColors.night,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(
                      progress.settings.fontScale.clamp(0.85, 1.35),
                    ),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
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
