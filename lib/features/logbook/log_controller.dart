import 'dart:async';
import 'dart:convert'; // Wajib ditambahkan untuk jsonEncode & jsonDecode
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';
import 'package:logbook_app_001/services/mongo_service.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  /// Notifier status koneksi: true = online, false = offline
  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier(true);

  StreamSubscription? _connectivitySub;

  // Kunci antrian pending sync di SharedPreferences
  static const String _pendingKey = 'pending_sync_ids';

  // Kunci unik untuk penyimpanan lokal di Shared Preferences
  static const String _storageKey = 'user_logs_data';

  // Getter untuk mempermudah akses list data saat ini
  List<LogModel> get logs => logsNotifier.value;

  // --- KONSTRUKTOR ---
  LogController();

  /// 1. LOAD DATA (Offline-First Strategy)
  Future<void> loadLogs(String teamId) async {
    final box = Hive.box<LogModel>('offline_logs');

    // Langkah 1: Ambil data dari Hive (Sangat Cepat/Instan)
    logsNotifier.value = box.values.where((l) => l.teamId == teamId).toList();

    // Langkah 2: Sync dari Cloud (Background)
    try {
      final cloudData = await MongoService().getLogs(teamId);

      // Ambil ID log yang masih pending (belum terkirim ke Atlas)
      final prefs = await SharedPreferences.getInstance();
      final pendingIds = prefs.getStringList(_pendingKey) ?? [];
      final pendingLogs = box.values
          .where((l) => l.id != null && pendingIds.contains(l.id))
          .toList();

      // Update Hive: data cloud + log offline yang masih pending
      await box.clear();
      await box.addAll(cloudData);
      for (final pending in pendingLogs) {
        // Hanya tambahkan jika belum ada di cloudData (benar-benar belum tersinkron)
        final alreadySynced = cloudData.any((c) => c.id == pending.id);
        if (!alreadySynced) await box.add(pending);
      }

      // Update UI: gabungkan cloud + pending
      final allLocal = box.values.where((l) => l.teamId == teamId).toList();
      logsNotifier.value = allLocal;

      await LogHelper.writeLog(
        "SYNC: Data berhasil diperbarui dari Atlas",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "OFFLINE: Menggunakan data cache lokal",
        level: 2,
      );
    }
  }

  /// 2. ADD DATA (Instant Local + Background Cloud)
  Future<void> addLog(
    String title,
    String desc,
    String authorId,
    String teamId, {
    bool isPublic = false,
    String category = 'Mechanical',
  }) async {
    final newLog = LogModel(
      id: ObjectId().oid,
      title: title,
      description: desc,
      date: DateTime.now().toString(),
      authorId: authorId,
      teamId: teamId,
      isPublic: isPublic,
      category: category,
    );

    // ACTION 1: Simpan ke Hive (Instan)
    final box = Hive.box<LogModel>('offline_logs');
    await box.add(newLog);
    logsNotifier.value = [...logsNotifier.value, newLog];

    // ACTION 2: Kirim ke MongoDB Atlas (Background)
    try {
      await MongoService().insertLog(newLog);
      await LogHelper.writeLog(
        "SUCCESS: Data tersinkron ke Cloud",
        source: "log_controller.dart",
      );
    } catch (e) {
      // Simpan ID ke antrian pending agar disinkronisasi saat online kembali
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingKey) ?? [];
      if (!pending.contains(newLog.id)) pending.add(newLog.id!);
      await prefs.setStringList(_pendingKey, pending);
      isOnlineNotifier.value = false;
      await LogHelper.writeLog(
        "WARNING: Data tersimpan lokal, akan sinkron saat online",
        level: 1,
      );
    }
  }

  // 2. Memperbarui data di Cloud (HOTS: Sinkronisasi Terjamin)
  Future<void> updateLog(
    int index,
    String newTitle,
    String newDesc, {
    String? category,
    bool? isPublic,
  }) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final oldLog = currentLogs[index];

    final updatedLog = LogModel(
      id: oldLog.id,
      title: newTitle,
      description: newDesc,
      date: DateTime.now().toString(),
      authorId: oldLog.authorId,
      teamId: oldLog.teamId,
      category: category ?? oldLog.category,
      isPublic: isPublic ?? oldLog.isPublic,
    );

    try {
      // 1. Jalankan update di MongoService (Tunggu konfirmasi Cloud)
      await MongoService().updateLog(updatedLog);

      // 2. Jika sukses, baru perbarui state lokal
      currentLogs[index] = updatedLog;
      logsNotifier.value = currentLogs;
      await _syncHive();

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Update '${oldLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Update - $e",
        source: "log_controller.dart",
        level: 1,
      );
      // Data di UI tidak berubah jika proses di Cloud gagal
    }
  }

  // 3. Menghapus data dari Cloud (HOTS: Sinkronisasi Terjamin)
  Future<void> removeLog(int index) async {
    final currentLogs = List<LogModel>.from(logsNotifier.value);
    final targetLog = currentLogs[index];

    try {
      if (targetLog.id == null) {
        throw Exception(
          "ID Log tidak ditemukan, tidak bisa menghapus di Cloud.",
        );
      }

      // 1. Hapus data di MongoDB Atlas (Tunggu konfirmasi Cloud)
      await MongoService().deleteLog(targetLog.id!);

      // 2. Jika sukses, baru hapus dari state lokal
      currentLogs.removeAt(index);
      logsNotifier.value = currentLogs;
      await _syncHive();

      await LogHelper.writeLog(
        "SUCCESS: Sinkronisasi Hapus '${targetLog.title}' Berhasil",
        source: "log_controller.dart",
        level: 2,
      );
    } catch (e) {
      await LogHelper.writeLog(
        "ERROR: Gagal sinkronisasi Hapus - $e",
        source: "log_controller.dart",
        level: 1,
      );
    }
  }

  // --- BARU: FUNGSI PERSISTENCE (SINKRONISASI JSON) ---

  // Fungsi untuk menyimpan seluruh List ke penyimpanan lokal
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    // Mengubah List of Object -> List of Map -> String JSON
    final String encodedData = jsonEncode(
      logsNotifier.value.map((log) => log.toMap()).toList(),
    );
    await prefs.setString(_storageKey, encodedData);
  }

  // Ganti pemanggilan SharedPreferences menjadi MongoService
  Future<void> loadFromDisk([String teamId = '']) async {
    // Mengambil dari Cloud, bukan lokal
    final cloudData = await MongoService().getLogs(teamId);
    logsNotifier.value = cloudData;
  }

  void searchLog(String text) {}

  // ─── Connectivity Watch ─────────────────────────────────────────────────────

  /// Mulai memantau perubahan koneksi. Panggil dari LogView.initState().
  void startConnectivityWatch(String teamId) {
    _connectivitySub?.cancel();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      // connectivity_plus v7 mengembalikan List<ConnectivityResult>
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      isOnlineNotifier.value = isOnline;
      if (isOnline) {
        await _syncPending(teamId);
      }
    });
  }

  /// Hentikan listener koneksi. Panggil dari LogView.dispose().
  void cancelWatch() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Kirim semua log yang tertunda ke Atlas menggunakan upsert (anti-duplikasi).
  Future<void> _syncPending(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingIds = prefs.getStringList(_pendingKey) ?? [];
    if (pendingIds.isEmpty) return;

    final box = Hive.box<LogModel>('offline_logs');
    final synced = <String>[];

    for (final id in pendingIds) {
      final log = box.values.cast<LogModel?>().firstWhere(
        (l) => l?.id == id,
        orElse: () => null,
      );
      if (log == null) {
        synced.add(id); // Log sudah tidak ada, hapus dari antrian
        continue;
      }
      try {
        // upsertLog mencegah duplikasi: insert jika baru, replace jika sudah ada
        await MongoService().upsertLog(log);
        synced.add(id);
      } catch (_) {}
    }

    if (synced.isNotEmpty) {
      final remaining = pendingIds.where((id) => !synced.contains(id)).toList();
      await prefs.setStringList(_pendingKey, remaining);
      // Reload dari cloud agar UI sinkron
      await loadLogs(teamId);
      await LogHelper.writeLog(
        "SYNC: ${synced.length} log offline berhasil dikirim ke Atlas",
        source: "log_controller.dart",
        level: 2,
      );
    }
  }

  // ─── Hive & Cloud Sync ──────────────────────────────────────────────────────

  /// Simpan state notifier saat ini ke Hive (offline cache).
  Future<void> _syncHive() async {
    final box = Hive.box<LogModel>('offline_logs');
    await box.clear();
    await box.addAll(logsNotifier.value);
  }
}
