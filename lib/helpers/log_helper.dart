import 'dart:developer' as dev;
import 'dart:io'; // TAMBAHKAN INI untuk akses file
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LogHelper {
  static String? _logsDirectoryPath;

  static Future<Directory> _getLogsDirectory() async {
    if (_logsDirectoryPath != null) {
      return Directory(_logsDirectoryPath!);
    }

    final String absoluteLogsPath =
        '${Directory.current.path}${Platform.pathSeparator}logs';
    final directory = Directory(absoluteLogsPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    _logsDirectoryPath = directory.path;
    return directory;
  }

  static Future<void> writeLog(
    String message, {
    String source = "Unknown",
    int level = 2,
  }) async {
    // 1. Filter Konfigurasi (ENV)
    final int configLevel = int.tryParse(dotenv.env['LOG_LEVEL'] ?? '2') ?? 2;
    final String muteList = dotenv.env['LOG_MUTE'] ?? '';
    final Set<String> mutedSources = muteList
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();

    if (level > configLevel) return;
    if (mutedSources.contains(source.trim().toLowerCase())) return;

    try {
      String timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
      String dateFile = DateFormat(
        'dd-MM-yyyy',
      ).format(DateTime.now()); // UNTUK NAMA FILE
      String label = _getLabel(level);
      String color = _getColor(level);

      // --- 2. LOGIKA PENULISAN FILE (KRITERIA LAB) ---
      try {
        final directory = await _getLogsDirectory();

        final file = File(
          '${directory.path}${Platform.pathSeparator}$dateFile.log',
        );
        // Tambahkan baris baru ke file (Append)
        await file.writeAsString(
          '[$timestamp][$label][$source] -> $message\n',
          mode: FileMode.append,
        );
      } catch (e) {
        dev.log("File logging failed: $e", name: "LOG_HELPER", level: 1000);
      }

      // 3. Output ke VS Code Debug Console
      dev.log(message, name: source, time: DateTime.now(), level: level * 100);

      // 4. Output ke Terminal dengan Warna (hanya jika LOG_LEVEL = 3)
      if (configLevel == 3) {
        print('$color[$timestamp][$label][$source] -> $message\x1B[0m');
      }
    } catch (e) {
      dev.log("Logging failed: $e", name: "SYSTEM", level: 1000);
    }
  }

  static String _getLabel(int level) {
    switch (level) {
      case 1:
        return "ERROR";
      case 2:
        return "INFO";
      case 3:
        return "VERBOSE";
      default:
        return "LOG";
    }
  }

  static String _getColor(int level) {
    switch (level) {
      case 1:
        return '\x1B[31m'; // Merah
      case 2:
        return '\x1B[32m'; // Hijau
      case 3:
        return '\x1B[34m'; // Biru
      default:
        return '\x1B[0m';
    }
  }
}
