import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/invitation_code_model.dart';

class FirebaseService {
  static const String _baseUrl = 'https://community-buildings56119-default-rtdb.asia-southeast1.firebasedatabase.app';
  static const String _apiKey = 'YOUR_FIREBASE_API_KEY'; // 需要從 Firebase Console 獲取
  
  // 初始化 Firebase
  static Future<void> initializeFirebase() async {
    try {
      // 初始化預設管理員帳號
      await _initializeDefaultAdmin();
      print('✅ Firebase 初始化成功');
    } catch (e) {
      print('❌ Firebase 初始化失敗: $e');
      rethrow;
    }
  }

  // 初始化預設管理員帳號
  static Future<void> _initializeDefaultAdmin() async {
    try {
      final adminData = await _getData('users/admin');
      if (adminData == null) {
        await _setData('users/admin', {
          'username': 'admin',
          'password': 'buildings56119',
          'name': '管理員',
          'role': '管理員',
          'building': '子敬園',
          'unit': '管理室',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('✅ 預設管理員帳號已創建');
      }
    } catch (e) {
      print('❌ 創建預設管理員帳號失敗: $e');
    }
  }

  // 通用 HTTP 方法
  static Future<dynamic> _getData(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$path.json'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting data from Firebase: $e');
      return null;
    }
  }

  static Future<bool> _setData(String path, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$path.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error setting data to Firebase: $e');
      return false;
    }
  }

  static Future<bool> _updateData(String path, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$path.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating data in Firebase: $e');
      return false;
    }
  }

  static Future<bool> _deleteData(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$path.json'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting data from Firebase: $e');
      return false;
    }
  }

  // 用戶相關操作
  static Future<UserModel?> getUserByUsername(String username) async {
    try {
      final data = await _getData('users/$username');
      if (data != null) {
        return UserModel.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    try {
      final data = await _getData('users');
      if (data != null) {
        return data.entries.map((entry) {
          final userData = entry.value as Map<dynamic, dynamic>;
          return UserModel.fromMap(Map<String, dynamic>.from(userData));
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  static Future<List<UserModel>> getAllResidents() async {
    try {
      final data = await _getData('users');
      if (data != null) {
        return data.entries
            .where((entry) {
              final userData = entry.value as Map<dynamic, dynamic>;
              return userData['role'] == '住戶';
            })
            .map((entry) {
              final userData = entry.value as Map<dynamic, dynamic>;
              return UserModel.fromMap(Map<String, dynamic>.from(userData));
            })
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting all residents: $e');
      return [];
    }
  }

  static Future<bool> createUser(UserModel user) async {
    try {
      return await _setData('users/${user.username}', {
        'username': user.username,
        'password': user.password,
        'name': user.name,
        'role': user.role,
        'building': user.building,
        'unit': user.unit,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  static Future<bool> updateUser(String username, String name, String unit) async {
    try {
      return await _updateData('users/$username', {
        'name': name,
        'unit': unit,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(String username) async {
    try {
      final userData = await _getData('users/$username');
      if (userData != null && userData['role'] != '管理員') {
        return await _deleteData('users/$username');
      }
      return false;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // 邀請碼相關操作
  static Future<List<InvitationCodeModel>> getAllInvitationCodes() async {
    try {
      final data = await _getData('invitation_codes');
      if (data != null) {
        return data.entries.map((entry) {
          final codeData = entry.value as Map<dynamic, dynamic>;
          return InvitationCodeModel.fromMap(Map<String, dynamic>.from(codeData));
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error getting all invitation codes: $e');
      return [];
    }
  }

  static Future<bool> createInvitationCode(InvitationCodeModel code) async {
    try {
      return await _setData('invitation_codes/${code.code}', {
        'code': code.code,
        'created_by': code.createdBy,
        'created_at': code.createdAt,
        'expires_at': code.expiresAt,
        'is_used': code.isUsed,
        'used_by': code.usedBy,
        'used_at': code.usedAt,
        'unit': code.unit,
      });
    } catch (e) {
      print('Error creating invitation code: $e');
      return false;
    }
  }

  static Future<bool> deleteInvitationCode(String code) async {
    try {
      return await _deleteData('invitation_codes/$code');
    } catch (e) {
      print('Error deleting invitation code: $e');
      return false;
    }
  }

  static Future<bool> useInvitationCode(String code, String username) async {
    try {
      final codeData = await _getData('invitation_codes/$code');
      if (codeData != null && codeData['is_used'] == false) {
        return await _updateData('invitation_codes/$code', {
          'is_used': true,
          'used_by': username,
          'used_at': DateTime.now().toIso8601String(),
        });
      }
      return false;
    } catch (e) {
      print('Error using invitation code: $e');
      return false;
    }
  }

  static Future<InvitationCodeModel?> getInvitationCode(String code) async {
    try {
      final data = await _getData('invitation_codes/$code');
      if (data != null) {
        return InvitationCodeModel.fromMap(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      print('Error getting invitation code: $e');
      return null;
    }
  }
} 