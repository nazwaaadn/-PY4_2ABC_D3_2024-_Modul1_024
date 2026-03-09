// login_controller.dart
class LoginController {
  final Map<String, String> _userDatabase = {
    "admin": "123",
    "user1": "pass1",
    "user2": "pass2",
    "budi": "budi123",
    "sari": "sari123",
    "doni": "doni123",
  };

  final Map<String, Map<String, dynamic>> _userData = {
    "admin": {
      "uid": "admin",
      "username": "Admin",
      "role": "Ketua",
      "teamId": "team_001",
    },
    "user1": {
      "uid": "user1",
      "username": "Nazwa",
      "role": "Anggota",
      "teamId": "team_001",
    },
    "user2": {
      "uid": "user2",
      "username": "Jay",
      "role": "Asisten",
      "teamId": "team_001",
    },
    "budi": {
      "uid": "budi",
      "username": "Budi",
      "role": "Ketua",
      "teamId": "team_002",
    },
    "sari": {
      "uid": "sari",
      "username": "Sari",
      "role": "Anggota",
      "teamId": "team_002",
    },
    "doni": {
      "uid": "doni",
      "username": "Doni",
      "role": "Ketua",
      "teamId": "team_003",
    },
  };

  bool login(String username, String password) {
    if (_userDatabase.containsKey(username) &&
        _userDatabase[username] == password) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> getUserData(String username) {
    return _userData[username] ??
        {
          'uid': username,
          'username': username,
          'role': 'Anggota',
          'teamId': 'team_001',
        };
  }
}
