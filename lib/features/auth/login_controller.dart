// login_controller.dart
class LoginController {
  // Database sederhana (Hardcoded)
  // final String _validUsername = "admin";
  // final String _validPassword = "123";

  final Map<String, String> _userDatabase = {
    "admin": "123",
    "user1": "pass1",
    "user2": "pass2",
  };


  // Fungsi pengecekan (Logic-Only)
  // Fungsi ini mengembalikan true jika cocok, false jika salah.
  bool login(String username, String password) {
    if (_userDatabase.containsKey(username) && _userDatabase[username] == password) {
      return true;
    }
    return false;
  }
}
