import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
import 'log_controller.dart';
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

class LogView extends StatefulWidget {
  LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String selectedCategory = "Pribadi";

  final List<String> categoryItems = ["Pribadi", "Kuliah", "Kerja", "Lainnya"];

  final Color primaryNavy = const Color(0xFF00264D);
  final Color accentOrange = const Color(0xFFFA9D1C);
  final Color bgColor = const Color(0xFFF8F9FE);

  @override
  void initState() {
    super.initState();
    _controller.logsNotifier.addListener(_syncFilteredLogs);
    _syncFilteredLogs();
  }

  void _syncFilteredLogs() {
    _controller.searchLog(_searchController.text);
  }

  int _findOriginalLogIndex(LogModel log) {
    return _controller.logsNotifier.value.indexWhere(
      (item) => item.date == log.date,
    );
  }

  @override
  void dispose() {
    _controller.logsNotifier.removeListener(_syncFilteredLogs);
    _titleController.dispose();
    _contentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBackBlocked();
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackBlocked,
          ),
          title: const Text(
            'Logbook',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          centerTitle: true,
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: _showLogoutDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primaryNavy,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: accentOrange,
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catatan Harian',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text(
                        'Kelola Log Aktivitas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _controller.searchLog(value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari catatan...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<List<LogModel>>(
                valueListenable: _controller.filteredLogs,
                builder: (context, currentLogs, child) {
                  if (currentLogs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 56,
                            color: primaryNavy.withOpacity(0.35),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Belum ada catatan.",
                            style: TextStyle(
                              color: primaryNavy.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: currentLogs.length,
                    itemBuilder: (context, index) {
                      final log = currentLogs[index];

                      return Dismissible(
                        key: Key(log.date),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          final originalIndex = _findOriginalLogIndex(log);
                          if (originalIndex != -1) {
                            _controller.removeLog(originalIndex);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Catatan dihapus")),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentOrange.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.note_rounded,
                                color: accentOrange,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              log.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryNavy,
                              ),
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    log.category,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Wrap(
                              spacing: 2,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    color: primaryNavy,
                                  ),
                                  onPressed: () => _showEditLogDialog(log),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    final originalIndex =
                                        _findOriginalLogIndex(log);
                                    if (originalIndex != -1) {
                                      _controller.removeLog(originalIndex);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          onPressed:
              _showAddLogDialog, // Panggil fungsi dialog yang baru dibuat
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _handleBackBlocked() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Anda harus logout terlebih dahulu untuk ke halaman login.',
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginView(fromLogout: true),
                ),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAddLogDialog() {
    selectedCategory = "Pribadi";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Catatan Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Agar dialog tidak memenuhi layar
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: "Judul Catatan"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(hintText: "Isi Deskripsi"),
            ),
            Padding(padding: const EdgeInsets.only(top: 10)),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Kategori",
              ),
              items: categoryItems.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup tanpa simpan
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Jalankan fungsi tambah di Controller
              _controller.addLog(
                _titleController.text,
                _contentController.text,
                selectedCategory,
              );

              // Bersihkan input dan tutup dialog
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditLogDialog(LogModel log) {
    _titleController.text = log.title;
    _contentController.text = log.description;
    String editedCategory = log.category;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Edit Catatan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Judul Catatan"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(hintText: "Isi Deskripsi"),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: editedCategory,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Kategori",
                ),
                items: categoryItems.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() {
                    editedCategory = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryNavy,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final originalIndex = _findOriginalLogIndex(log);
                if (originalIndex != -1) {
                  _controller.updateLog(
                    originalIndex,
                    _titleController.text,
                    _contentController.text,
                    editedCategory,
                  );
                }
                _titleController.clear();
                _contentController.clear();
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
