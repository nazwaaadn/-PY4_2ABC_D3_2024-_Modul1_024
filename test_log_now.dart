// Quick test: Apakah logging berfungsi?
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/helpers/log_helper.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  
  print('\n🔍 Testing Logging System...\n');
  print('LOG_LEVEL: ${dotenv.env['LOG_LEVEL']}');
  print('LOG_MUTE: "${dotenv.env['LOG_MUTE']}"\n');
  
  await LogHelper.writeLog(
    'TEST MANUAL: Tambah data dari test script',
    source: 'test_log_now.dart',
    level: 2,
  );
  
  await LogHelper.writeLog(
    'TEST VERBOSE: Detail proses',
    source: 'test_log_now.dart',
    level: 3,
  );
  
  print('\n✅ Log ditulis! Cek file logs/02-03-2026.log\n');
}
