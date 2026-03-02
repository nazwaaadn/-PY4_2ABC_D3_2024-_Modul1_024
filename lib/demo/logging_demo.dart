// DEMO: Verifikasi LOG_LEVEL mempengaruhi output log
//
// Cara menjalankan:
// 1. dart run lib/demo/logging_demo.dart
// 2. Ubah LOG_LEVEL di .env (1, 2, atau 3)
// 3. Run ulang script ini
// 4. Perhatikan perbedaan output di terminal dan file logs/dd-mm-yyyy.log

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

Future<void> main() async {
  // Load .env
  await dotenv.load(fileName: ".env");

  final currentLevel = dotenv.env['LOG_LEVEL'] ?? '2';

  print('\n╔════════════════════════════════════════════════════════════╗');
  print('║       DEMO SISTEM LOGGING - KRITERIA LAB                  ║');
  print('╚════════════════════════════════════════════════════════════╝\n');
  print('📌 LOG_LEVEL saat ini: $currentLevel\n');

  // Simulasi berbagai level log
  print('🔵 Menulis log LEVEL 1 (ERROR)...');
  await LogHelper.writeLog(
    'Ini adalah pesan ERROR - selalu tercatat',
    source: 'logging_demo.dart',
    level: 1,
  );

  print('🟢 Menulis log LEVEL 2 (INFO)...');
  await LogHelper.writeLog(
    'Ini adalah pesan INFO - tercatat jika LOG_LEVEL >= 2',
    source: 'logging_demo.dart',
    level: 2,
  );

  print('🟡 Menulis log LEVEL 3 (VERBOSE)...');
  await LogHelper.writeLog(
    'Ini adalah pesan VERBOSE - hanya tercatat jika LOG_LEVEL = 3',
    source: 'logging_demo.dart',
    level: 3,
  );

  print('\n✅ Demo selesai!\n');
  print('╔════════════════════════════════════════════════════════════╗');
  print('║  Hasil yang diharapkan berdasarkan LOG_LEVEL:            ║');
  print('╠════════════════════════════════════════════════════════════╣');
  print('║  LOG_LEVEL=1 → Hanya ERROR tercatat                      ║');
  print('║  LOG_LEVEL=2 → ERROR + INFO tercatat (default)           ║');
  print('║  LOG_LEVEL=3 → ERROR + INFO + VERBOSE tercatat (full)    ║');
  print('╠════════════════════════════════════════════════════════════╣');
  print('║  Terminal output → Hanya muncul jika LOG_LEVEL=3         ║');
  print('║  File log       → Selalu tercatat sesuai level           ║');
  print('╚════════════════════════════════════════════════════════════╝\n');

  print(
    '📂 Cek file log di: logs/${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}.log\n',
  );
  print('💡 Tips: Ubah LOG_LEVEL di .env lalu run ulang script ini!\n');
}
