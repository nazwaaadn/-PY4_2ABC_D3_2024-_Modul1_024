// login_view.dart
import 'package:flutter/material.dart';
// Import Controller milik sendiri (masih satu folder)
import 'package:logbook_app_001/features/auth/login_controller.dart';
// Import View dari fitur lain (Logbook) untuk navigasi
import 'package:logbook_app_001/features/logbook/counter_view.dart';
import 'dart:async';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Inisialisasi Otak dan Controller Input
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  int _failedAttempts = 0;
  bool _isButtonDisabled = false;
  Timer? _lockTimer;
  bool _isPasswordHidden = true;


  void _handleLogin() {
    if (_isButtonDisabled) return;

    String user = _userController.text.trim();
    String pass = _passController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Field tidak boleh kosong")));
      return;
    }

    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      _failedAttempts = 0;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CounterView(username: user)),
      );
    } else {
      setState(() {
        _failedAttempts++;
      });

      if (_failedAttempts >= 3) {
        setState(() {
          _isButtonDisabled = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terlalu banyak percobaan gagal. Tunggu 10 detik."),
          ),
        );

        _lockTimer = Timer(const Duration(seconds: 10), () {
          if (!mounted) return;

          setState(() {
            _failedAttempts = 0;
            _isButtonDisabled = false;
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login gagal ($_failedAttempts/3)")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passController,
              obscureText: true, // Menyembunyikan teks password
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _handleLogin, child: const Text("Masuk")),
          ],
        ),
      ),
    );
  }
}
