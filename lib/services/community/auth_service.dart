import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _currentUserId = '';
  String _userRole = '';
  String _userName = '';
  String _userUnit = '';

  bool get isAuthenticated => _isAuthenticated;
  String get currentUserId => _currentUserId;
  String get userRole => _userRole;
  String get userName => _userName;
  String get userUnit => _userUnit;

  Future<bool> login(String username, String password) async {
    try {
      final result = await FirebaseService.login(username, password);
      if (result != null && result['success'] == true) {
        final user = result['user'];
        _isAuthenticated = true;
        _currentUserId = username;
        _userRole = user['role'];
        _userName = user['name'];
        _userUnit = user['unit'] ?? '';

        // 保存登入狀態
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('currentUserId', _currentUserId);
        await prefs.setString('userRole', _userRole);
        await prefs.setString('userName', _userName);
        await prefs.setString('userUnit', _userUnit);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUserId = '';
    _userRole = '';
    _userName = '';
    _userUnit = '';

    // 清除登入狀態
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('currentUserId');
    await prefs.remove('userRole');
    await prefs.remove('userName');
    await prefs.remove('userUnit');

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _currentUserId = prefs.getString('currentUserId') ?? '';
    _userRole = prefs.getString('userRole') ?? '';
    _userName = prefs.getString('userName') ?? '';
    _userUnit = prefs.getString('userUnit') ?? '';
    notifyListeners();
  }

  bool get isAdmin => _userRole == '管理員';
  bool get isResident => _userRole == '住戶';

  // 刪除用戶（僅管理員可用）
  Future<Map<String, dynamic>> deleteUser(String username) async {
    if (!isAdmin) {
      return {'success': false, 'message': '權限不足，僅管理員可刪除用戶'};
    }
    try {
      final result = await FirebaseService.deleteResident(username);
      return result;
    } catch (e) {
      return {'success': false, 'message': '刪除用戶失敗：$e'};
    }
  }

  // 獲取所有住戶列表
  Future<Map<String, dynamic>> getAllResidents() async {
    try {
      final result = await FirebaseService.getAllResidents();
      return result ?? {'success': false, 'message': '獲取住戶列表失敗'};
    } catch (e) {
      return {'success': false, 'message': '獲取住戶列表失敗：$e'};
    }
  }

  // 測試 Firebase 連接
  Future<bool> testBackendConnection() async {
    try {
      final result = await FirebaseService.getAllUsers();
      return result != null && result['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // 獲取當前用戶信息
  Map<String, dynamic>? getCurrentUserInfo() {
    return {
      'username': _currentUserId,
      'name': _userName,
      'role': _userRole,
      'unit': _userUnit,
    };
  }
} 