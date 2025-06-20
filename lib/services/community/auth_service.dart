import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../serverpod_client.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _currentUserId = '';
  String _userRole = '';
  String _userName = '';
  bool _useServerpod = true; // 是否使用Serverpod後端

  bool get isAuthenticated => _isAuthenticated;
  String get currentUserId => _currentUserId;
  String get userRole => _userRole;
  String get userName => _userName;

  // 模擬用戶數據 - 子敬園住戶（本地備用）
  static const Map<String, Map<String, dynamic>> _mockUsers = {
    'admin': {
      'password': 'buildings56119',
      'role': '管理員',
      'name': '管理員',
      'building': '子敬園',
      'unit': '管理室',
    },
    'dogbone0714': {
      'password': 'abc054015',
      'role': '住戶',
      'name': '康皓雄',
      'building': '子敬園',
      'unit': '5667',
    },
    'resident2': {
      'password': 'resident123',
      'role': '住戶',
      'name': '李小華',
      'building': '子敬園',
      'unit': '2202',
    },
    'resident3': {
      'password': 'resident123',
      'role': '住戶',
      'name': '王美玲',
      'building': '子敬園',
      'unit': '3303',
    },
  };

  Future<bool> login(String username, String password) async {
    if (_useServerpod) {
      // 使用 Serverpod 後端
      try {
        final result = await ServerpodClientService.login(username, password);
        if (result != null && result['success'] == true) {
          final user = result['user'];
          _isAuthenticated = true;
          _currentUserId = username;
          _userRole = user['role'];
          _userName = user['name'];

          // 保存登入狀態
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);
          await prefs.setString('currentUserId', _currentUserId);
          await prefs.setString('userRole', _userRole);
          await prefs.setString('userName', _userName);

          notifyListeners();
          return true;
        } else {
          // 如果 Serverpod 失敗，回退到本地認證
          _useServerpod = false;
          return await _localLogin(username, password);
        }
      } catch (e) {
        print('Serverpod login failed, falling back to local: $e');
        _useServerpod = false;
        return await _localLogin(username, password);
      }
    } else {
      // 使用本地認證
      return await _localLogin(username, password);
    }
  }

  Future<bool> _localLogin(String username, String password) async {
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
  
  // 測試後端連接
  Future<bool> testBackendConnection() async {
    try {
      final result = await ServerpodClientService.testConnection();
      return result != null && result['success'] == true;
    } catch (e) {
      return false;
    }
  }
} 