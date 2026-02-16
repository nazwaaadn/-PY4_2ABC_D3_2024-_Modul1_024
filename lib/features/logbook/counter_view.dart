import 'package:flutter/material.dart';
import 'counter_controller.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:logbook_app_001/features/onboarding/onboarding_view.dart';

class CounterView extends StatefulWidget {
  // Tambahkan variabel final untuk menampung nama
  final String username;

  // Update Constructor agar mewajibkan (required) kiriman nama
  const CounterView({super.key, required this.username});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late CounterController _controller;
  String _inputValue = "";
  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _controller = CounterController(widget.username);
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadLastValue();
    await _controller.loadHistory();
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Logbook: ${widget.username}"),
        backgroundColor: const Color.fromARGB(
          255,
          0,
          38,
          77,
        ), // biru navy gelap

        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi Logout"),
                    content: const Text("Apakah Anda yakin ingin keluar?"),
                    actions: [
                      // Tombol Batal
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog saja
                        },
                        child: const Text("Batal"),
                      ),

                      // Tombol Ya, Logout
                      TextButton(
                        onPressed: () {
                          // Tutup dialog dulu
                          Navigator.pop(context);

                          // Hapus semua halaman & kembali ke Onboarding
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingView(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Ya, Keluar",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Selamat Datang, ${widget.username}!"),
            const SizedBox(height: 40),
            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 30),

            Column(
              children: [
                Slider(
                  value: _controller.step.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _controller.step.toString(),
                  activeColor: const Color.fromARGB(
                    255,
                    0,
                    38,
                    77,
                  ), // warna bagian yang sudah digeser
                  inactiveColor:
                      Colors.grey[300], // warna track yang belum digeser
                  onChanged: (double value) {
                    setState(() {
                      _controller.setStep(value.toInt());
                    });
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Step saat ini: ${_controller.step}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Riwayat Aktivitas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final item = _controller.history[index];
                  Color textColor = Colors.black;
                  IconData iconData = Icons.info; // default icon

                  if (item.action.contains("menambah")) {
                    textColor = Colors.green;
                    iconData = Icons.add_circle; // icon untuk menambah
                  } else if (item.action.contains("mengurangi")) {
                    textColor = Colors.red;
                    iconData = Icons.remove_circle; // icon untuk mengurangi
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(iconData, color: textColor, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "${item.action} ${item.value}",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(item.time),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu, // icon FAB utama
        activeIcon: Icons.close, // icon saat terbuka
        backgroundColor: const Color(0xFFFA9D1C),
        foregroundColor: Colors.white,
        closeManually: false,
        spacing: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.remove),
            backgroundColor: Colors.red,
            // label: "Decrement",
            onTap: () async {
              setState(() {
                _controller.decrement();
              });

              await _controller.saveLastValue(_controller.value);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.green,
            // label: "Increment",
            onTap: () async {
              setState(() => _controller.increment());
              await _controller.saveLastValue(_controller.value);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            backgroundColor: const Color(0xFFFA9D1C),
            // label: "Reset",
            onTap: _resetPopUp,
          ),
        ],
      ),
    );
  }

  void _resetPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Reset"),
          content: const Text("Apakah kamu yakin ingin mereset?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
             
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // Batal merah
              ),
              child: const Text("Batal"),
            ),
            FilledButton(
              // onPressed: () {
              //   setState(() => _controller.reset());
              //   Navigator.pop(context);
              // },
              onPressed: () async {
                Navigator.pop(context); 

                setState(() {
                  _controller.reset();
                });

                await _controller.saveLastValue(_controller.value);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  255,
                  250,
                  157,
                  28,
                ), // OK hijau
                foregroundColor: Colors.white,
              ),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
