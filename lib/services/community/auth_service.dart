import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _currentUserId = '';
  String _userRole = '';
  String _userName = '';

  bool get isAuthenticated => _isAuthenticated;
  String get currentUserId => _currentUserId;
  String get userRole => _userRole;
  String get userName => _userName;

  // 模擬用戶數據
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    'admin': {
      'password': 'admin123',
      'role': '管理員',
      'name': '管理員',
      'building': 'A棟',
      'unit': '管理室',
    },
    'resident1': {
      'password': 'resident123',
      'role': '住戶',
      'name': '張小明',
      'building': 'A棟',
      'unit': '1001',
    },
    'resident2': {
      'password': 'resident123',
      'role': '住戶',
      'name': '李小華',
      'building': 'B棟',
      'unit': '2002',
    },
  };

  Future<bool> login(String username, String password) async {
    // 模擬網路延遲
    await Future.delayed(const Duration(seconds: 1));

    if (_mockUsers.containsKey(username) && 
        _mockUsers[username]!['password'] == password) {
      _isAuthenticated = true;
      _currentUserId = username;
      _userRole = _mockUsers[username]!['role'];
      _userName = _mockUsers[username]!['name'];

      // 保存登入狀態
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('currentUserId', _currentUserId);
      await prefs.setString('userRole', _userRole);
      await prefs.setString('userName', _userName);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUserId = '';
    _userRole = '';
    _userName = '';

    // 清除登入狀態
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('currentUserId');
    await prefs.remove('userRole');
    await prefs.remove('userName');

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _currentUserId = prefs.getString('currentUserId') ?? '';
    _userRole = prefs.getString('userRole') ?? '';
    _userName = prefs.getString('userName') ?? '';
    notifyListeners();
  }

  Map<String, dynamic>? getCurrentUserInfo() {
    if (_mockUsers.containsKey(_currentUserId)) {
      return _mockUsers[_currentUserId];
    }
    return null;
  }

  bool get isAdmin => _userRole == '管理員';
  bool get isResident => _userRole == '住戶';
} 