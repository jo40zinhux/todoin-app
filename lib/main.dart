import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'core/config/observability_config.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/presentation/app_bootstrap.dart';
import 'core/services/analytics_service.dart';
import 'core/services/billing_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/live_activity_service.dart';
import 'core/services/foreground_service.dart';
import 'core/services/widget_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  await BillingService.instance.initialize();
  await AnalyticsService.instance.initialize();
  await NotificationService.instance.initialize();
  await LiveActivityService.instance.initialize();
  ForegroundService.instance.initCommunicationPort();
  await ForegroundService.instance.requestPermissions();
  await WidgetDataService.instance.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();

  Future<void> runTodoinApp() async {
    AnalyticsService.instance.appOpened();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const TodoinApp(),
      ),
    );
  }

  if (ObservabilityConfig.hasSentry) {
    await SentryFlutter.init(
      (options) {
        options.dsn = ObservabilityConfig.sentryDsn;
        options.tracesSampleRate = 0.15;
        options.environment = kReleaseMode ? 'production' : 'development';
      },
      appRunner: runTodoinApp,
    );
  } else {
    await runTodoinApp();
  }
}

/// Aplicativo Todoin Focus — ajuda pessoas com TDAH a iniciar
/// tarefas, manter foco e reduzir procrastinação.
class TodoinApp extends StatelessWidget {
  const TodoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF7C5CFC);

    return MaterialApp(
      title: 'toDoin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AppBootstrap(),
    );
  }
}
