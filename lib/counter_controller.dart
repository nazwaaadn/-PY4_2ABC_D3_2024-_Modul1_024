class HistoryItem {
  final String action;
  final int value;
  final DateTime time;

  HistoryItem({
    required this.action,
    required this.value,
    required this.time,
  });
}

class CounterController {
  int _counter = 0;
  int _step = 1;
  final List<HistoryItem> _history = [];

  int get value => _counter;
  int get step => _step;
  List<HistoryItem> get history => List.unmodifiable(_history);

  void setStep(int step) {
    if (step > 0) _step = step;
  }

  void increment() {
    _counter += _step;
    _addHistory("User menambah nilai sebesar", _step);
  }

  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addHistory("User mengurangi nilai sebesar", _step);
    }
  }

  void reset() {
    _counter = 0;
    _addHistory("User Reset nilai menjadi", _counter);
  }

  void _addHistory(String action, int value) {
    _history.insert(0, 
      HistoryItem(
        action: action,
        value: value,
        time: DateTime.now()
      ),
    );

    if (_history.length > 5) {
      _history.removeLast();
    }
  }
}
