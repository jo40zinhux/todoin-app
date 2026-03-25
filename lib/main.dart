import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/tasks/presentation/providers/tasks_provider.dart';
import 'features/tasks/presentation/screens/home_screen.dart';
import 'core/services/notification_service.dart';
import 'core/services/live_activity_service.dart';
import 'core/services/foreground_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviços de notificação e background
  await NotificationService.instance.initialize();
  await LiveActivityService.instance.initialize();
  ForegroundService.instance.initCommunicationPort();
  await ForegroundService.instance.requestPermissions();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const TodoinApp(),
    ),
  );
}

/// Aplicativo Todoin Focus — ajuda pessoas com TDAH a iniciar
/// tarefas, manter foco e reduzir procrastinação.
class TodoinApp extends StatelessWidget {
  const TodoinApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta de cores suave e amigável (lavanda / teal).
    const seedColor = Color(0xFF7C5CFC); // Lavanda vibrante

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
      home: const HomeScreen(),
    );
  }
}
