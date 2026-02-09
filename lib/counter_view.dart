import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});
  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  final CounterController _controller = CounterController();
  String _inputValue = "";
  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')}:"
        "${time.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LogBook: Versi SRP")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Hitungan:"),
            Text('${_controller.value}', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 20),

            // TEXT FIELD TANPA controller:
            SizedBox(
              width: 200,
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Masukkan angka",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _inputValue = value;
                },
              ),
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(_inputValue);
                if (input != null) {
                  setState(() => _controller.setStep(input));
                }
              },
              child: const Text("Set Nilai"),
            ),

            const SizedBox(height: 16),

            Text("Step saat ini: ${_controller.step}"),

            const Divider(height: 30),

            const Text(
              "Riwayat Aktivitas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  final item = _controller.history[index];
                  return ListTile(
                    title: Text("${item.action} → ${item.value}"),
                    subtitle: Text(_formatTime(item.time)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: () => setState(() => _controller.decrement()),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: () => setState(() => _controller.increment()),
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'reset',
            onPressed: () => setState(() => _controller.reset()),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
