// main.dart
import 'package:flutter/material.dart';
// Sesuaikan path import dengan struktur folder baru
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

void main() async {
  // Wajib untuk operasi asinkron sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  // Load ENV
  await dotenv.load(fileName: ".env");

  // INISIALISASI HIVE
  await Hive.initFlutter();
  Hive.registerAdapter(LogModelAdapter()); // WAJIB: Sesuai nama di .g.dart
  await Hive.openBox<LogModel>(
    'offline_logs',
  ); // Buka box sebelum Controller dipakai
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogBook App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const OnboardingView(),
    );
  }
}
