import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/community/resident.dart';
import '../../models/invitation_code.dart';

class FirebaseService {
  static const String _baseUrl = 'https://community-buildings56119-default-rtdb.asia-southeast1.firebasedatabase.app';
  
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
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final data = await _getData('users/$username');
      if (data != null && data['password'] == password) {
        return {
          'success': true,
          'user': {
            'username': data['username'],
            'name': data['name'],
            'role': data['role'],
            'building': data['building'],
            'unit': data['unit'],
          },
        };
      }
      return {'success': false, 'message': '帳號或密碼錯誤'};
    } catch (e) {
      return {'success': false, 'message': '登入失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>?> getUserInfo(String username) async {
    try {
      final data = await _getData('users/$username');
      if (data != null) {
        return {
          'success': true,
          'user': {
            'username': data['username'],
            'name': data['name'],
            'role': data['role'],
            'building': data['building'],
            'unit': data['unit'],
          },
        };
      }
      return {'success': false, 'message': '用戶不存在'};
    } catch (e) {
      return {'success': false, 'message': '獲取用戶信息失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>?> getAllUsers() async {
    try {
      final data = await _getData('users');
      if (data != null) {
        final users = data.entries.map((entry) {
          final userData = entry.value as Map<dynamic, dynamic>;
          return {
            'username': userData['username'],
            'name': userData['name'],
            'role': userData['role'],
            'building': userData['building'],
            'unit': userData['unit'],
            'created_at': userData['created_at'],
          };
        }).toList();
        
        return {
          'success': true,
          'users': users,
        };
      }
      return {'success': true, 'users': []};
    } catch (e) {
      return {'success': false, 'message': '獲取用戶列表失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>?> getAllResidents() async {
    try {
      final data = await _getData('users');
      if (data != null) {
        final residents = data.entries
            .where((entry) {
              final userData = entry.value as Map<dynamic, dynamic>;
              return userData['role'] == '住戶';
            })
            .map((entry) {
              final userData = entry.value as Map<dynamic, dynamic>;
              return {
                'username': userData['username'],
                'name': userData['name'],
                'role': userData['role'],
                'building': userData['building'],
                'unit': userData['unit'],
                'created_at': userData['created_at'],
              };
            })
            .toList();
        
        return {
          'success': true,
          'residents': residents,
        };
      }
      return {'success': true, 'residents': []};
    } catch (e) {
      return {'success': false, 'message': '獲取住戶列表失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> addResident(
    String username,
    String password,
    String name,
    String unit,
  ) async {
    try {
      // 檢查用戶名是否已存在
      final existingUser = await _getData('users/$username');
      if (existingUser != null) {
        return {'success': false, 'message': '用戶名已存在'};
      }

      final success = await _setData('users/$username', {
        'username': username,
        'password': password,
        'name': name,
        'role': '住戶',
        'building': '子敬園',
        'unit': unit,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (success) {
        return {'success': true, 'message': '住戶新增成功'};
      } else {
        return {'success': false, 'message': '新增住戶失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '新增住戶失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> deleteResident(String username) async {
    try {
      if (username == 'admin') {
        return {'success': false, 'message': '管理員帳號不可刪除'};
      }

      final success = await _deleteData('users/$username');
      
      if (success) {
        return {'success': true, 'message': '住戶刪除成功'};
      } else {
        return {'success': false, 'message': '刪除住戶失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '刪除住戶失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> updateResidentInfo(
    String username,
    String name,
    String unit,
  ) async {
    try {
      final success = await _updateData('users/$username', {
        'name': name,
        'unit': unit,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (success) {
        return {'success': true, 'message': '住戶信息更新成功'};
      } else {
        return {'success': false, 'message': '更新住戶信息失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '更新住戶信息失敗：$e'};
    }
  }

  // 邀請碼相關操作
  static Future<Map<String, dynamic>> generateInvitationCode(
    String createdBy, {
    int? validDays,
    String? unit,
  }) async {
    try {
      final code = 'ABC${DateTime.now().millisecondsSinceEpoch % 1000}';
      final expiresAt = DateTime.now().add(Duration(days: validDays ?? 7));
      
      final success = await _setData('invitation_codes/$code', {
        'code': code,
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'is_used': false,
        'used_by': null,
        'used_at': null,
        'unit': unit,
      });

      if (success) {
        return {
          'success': true,
          'message': '邀請碼生成成功',
          'code': code,
        };
      } else {
        return {'success': false, 'message': '生成邀請碼失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '生成邀請碼失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> getAllInvitationCodes() async {
    try {
      final data = await _getData('invitation_codes');
      if (data != null) {
        final codes = data.entries.map((entry) {
          final codeData = entry.value as Map<dynamic, dynamic>;
          return {
            'code': codeData['code'],
            'created_by': codeData['created_by'],
            'created_at': codeData['created_at'],
            'expires_at': codeData['expires_at'],
            'is_used': codeData['is_used'],
            'used_by': codeData['used_by'],
            'used_at': codeData['used_at'],
            'unit': codeData['unit'],
          };
        }).toList();
        
        return {
          'success': true,
          'codes': codes,
        };
      }
      return {'success': true, 'codes': []};
    } catch (e) {
      return {'success': false, 'message': '獲取邀請碼列表失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> deleteInvitationCode(String code) async {
    try {
      final success = await _deleteData('invitation_codes/$code');
      
      if (success) {
        return {'success': true, 'message': '邀請碼刪除成功'};
      } else {
        return {'success': false, 'message': '刪除邀請碼失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '刪除邀請碼失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> validateInvitationCode(String code) async {
    try {
      final data = await _getData('invitation_codes/$code');
      
      if (data == null) {
        return {'success': false, 'message': '邀請碼不存在'};
      }
      
      if (data['is_used'] == true) {
        return {'success': false, 'message': '邀請碼已被使用'};
      }
      
      final expiresAt = DateTime.parse(data['expires_at']);
      if (expiresAt.isBefore(DateTime.now())) {
        return {'success': false, 'message': '邀請碼已過期'};
      }
      
      return {
        'success': true,
        'message': '邀請碼有效',
        'code': data,
      };
    } catch (e) {
      return {'success': false, 'message': '驗證邀請碼失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> useInvitationCode(String code, String username) async {
    try {
      final data = await _getData('invitation_codes/$code');
      if (data != null && data['is_used'] == false) {
        final success = await _updateData('invitation_codes/$code', {
          'is_used': true,
          'used_by': username,
          'used_at': DateTime.now().toIso8601String(),
        });
        
        if (success) {
          return {'success': true, 'message': '邀請碼使用成功'};
        }
      }
      return {'success': false, 'message': '使用邀請碼失敗'};
    } catch (e) {
      return {'success': false, 'message': '使用邀請碼失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String password,
    String name,
    String role,
    String building,
    String unit,
  ) async {
    try {
      // 檢查用戶名是否已存在
      final existingUser = await _getData('users/$username');
      if (existingUser != null) {
        return {'success': false, 'message': '用戶名已存在'};
      }

      final success = await _setData('users/$username', {
        'username': username,
        'password': password,
        'name': name,
        'role': role,
        'building': building,
        'unit': unit,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (success) {
        return {'success': true, 'message': '註冊成功'};
      } else {
        return {'success': false, 'message': '註冊失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '註冊失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> registerWithInvitationCode(
    String code,
    String username,
    String password,
    String name,
    String unit,
  ) async {
    try {
      final validateResult = await validateInvitationCode(code);
      if (validateResult['success'] != true) {
        return validateResult;
      }
      
      final useResult = await useInvitationCode(code, username);
      if (useResult['success'] != true) {
        return useResult;
      }
      
      final registerResult = await register(
        username,
        password,
        name,
        '住戶',
        '子敬園',
        unit,
      );
      
      return registerResult;
    } catch (e) {
      return {'success': false, 'message': '註冊失敗：$e'};
    }
  }
} 