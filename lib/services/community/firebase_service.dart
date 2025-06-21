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
        final userData = data as Map<dynamic, dynamic>;
        return {
          'success': true,
          'user': {
            'username': userData['username']?.toString() ?? username,
            'name': userData['name']?.toString() ?? '未知用戶',
            'role': userData['role']?.toString() ?? '住戶',
            'building': userData['building']?.toString() ?? '',
            'unit': userData['unit']?.toString() ?? '',
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
        final userData = data as Map<dynamic, dynamic>;
        return {
          'success': true,
          'user': {
            'username': userData['username']?.toString() ?? username,
            'name': userData['name']?.toString() ?? '未知用戶',
            'role': userData['role']?.toString() ?? '住戶',
            'building': userData['building']?.toString() ?? '',
            'unit': userData['unit']?.toString() ?? '',
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
            'username': userData['username']?.toString() ?? '',
            'name': userData['name']?.toString() ?? '',
            'role': userData['role']?.toString() ?? '',
            'building': userData['building']?.toString() ?? '',
            'unit': userData['unit']?.toString() ?? '',
            'created_at': userData['created_at']?.toString() ?? '',
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
              return userData['role']?.toString() == '住戶';
            })
            .map((entry) {
              final userData = entry.value as Map<dynamic, dynamic>;
              return {
                'username': userData['username']?.toString() ?? '',
                'name': userData['name']?.toString() ?? '',
                'role': userData['role']?.toString() ?? '',
                'building': userData['building']?.toString() ?? '',
                'unit': userData['unit']?.toString() ?? '',
                'created_at': userData['created_at']?.toString() ?? '',
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
        // 添加活動記錄
        await addActivity(
          'invitation_code',
          '生成邀請碼',
          '生成邀請碼：$code${unit != null ? ' (${unit})' : ''}',
          createdBy,
          '管理員',
          metadata: {
            'code': code,
            'unit': unit,
            'valid_days': validDays ?? 7,
          },
        );
        
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
            'code': codeData['code']?.toString() ?? '',
            'created_by': codeData['created_by']?.toString() ?? '',
            'created_at': codeData['created_at']?.toString() ?? '',
            'expires_at': codeData['expires_at']?.toString() ?? '',
            'is_used': codeData['is_used'] ?? false,
            'used_by': codeData['used_by']?.toString(),
            'used_at': codeData['used_at']?.toString(),
            'unit': codeData['unit']?.toString(),
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

  // 公告相關操作
  static Future<Map<String, dynamic>> getAllAnnouncements() async {
    try {
      final data = await _getData('announcements');
      if (data != null) {
        final announcements = data.entries.map((entry) {
          final announcementData = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key,
            'title': announcementData['title']?.toString() ?? '',
            'content': announcementData['content']?.toString() ?? '',
            'created_by': announcementData['created_by']?.toString() ?? '',
            'created_at': announcementData['created_at']?.toString() ?? '',
          };
        }).toList();
        
        return {
          'success': true,
          'announcements': announcements,
        };
      }
      return {'success': true, 'announcements': []};
    } catch (e) {
      return {'success': false, 'message': '獲取公告列表失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> addAnnouncement(
    String title,
    String content,
  ) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final success = await _setData('announcements/$id', {
        'title': title,
        'content': content,
        'created_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (success) {
        // 添加活動記錄，包含公告的完整內容
        await addActivity(
          'announcement',
          '發布公告',
          '發布公告：$title',
          'admin',
          '管理員',
          metadata: {
            'announcement_id': id,
            'title': title,
            'content': content,
            'full_content': content, // 存儲完整內容用於顯示
          },
        );
        
        return {'success': true, 'message': '公告新增成功'};
      } else {
        return {'success': false, 'message': '新增公告失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '新增公告失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAnnouncement(String id) async {
    try {
      // 獲取公告信息用於活動記錄
      final announcementData = await _getData('announcements/$id');
      String announcementTitle = '未知公告';
      
      if (announcementData != null) {
        final announcement = announcementData as Map<dynamic, dynamic>;
        announcementTitle = announcement['title']?.toString() ?? '未知公告';
      }

      final success = await _deleteData('announcements/$id');
      
      if (success) {
        // 添加活動記錄
        await addActivity(
          'announcement',
          '刪除公告',
          '刪除公告：$announcementTitle',
          'admin',
          '管理員',
          metadata: {
            'announcement_id': id,
            'title': announcementTitle,
          },
        );
        
        return {'success': true, 'message': '公告刪除成功'};
      } else {
        return {'success': false, 'message': '刪除公告失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '刪除公告失敗：$e'};
    }
  }

  // 維修請求相關操作
  static Future<Map<String, dynamic>> getAllMaintenanceRequests() async {
    try {
      final data = await _getData('maintenance_requests');
      if (data != null) {
        final requests = data.entries.map((entry) {
          final requestData = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key,
            'title': requestData['title']?.toString() ?? '',
            'description': requestData['description']?.toString() ?? '',
            'status': requestData['status']?.toString() ?? 'pending',
            'created_by': requestData['created_by']?.toString() ?? '',
            'created_at': requestData['created_at']?.toString() ?? '',
          };
        }).toList();
        
        return {
          'success': true,
          'requests': requests,
        };
      }
      return {'success': true, 'requests': []};
    } catch (e) {
      return {'success': false, 'message': '獲取維修請求列表失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> addMaintenanceRequest(
    String title,
    String description,
  ) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final success = await _setData('maintenance_requests/$id', {
        'title': title,
        'description': description,
        'status': 'pending',
        'created_by': 'resident',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (success) {
        // 添加活動記錄
        await addActivity(
          'maintenance_request',
          '提交維修請求',
          '提交維修請求：$title',
          'resident',
          '住戶',
          metadata: {
            'request_id': id,
            'title': title,
            'status': 'pending',
          },
        );
        
        return {'success': true, 'message': '維修請求提交成功'};
      } else {
        return {'success': false, 'message': '提交維修請求失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '提交維修請求失敗：$e'};
    }
  }

  static Future<bool> updateMaintenanceRequestStatus(String id, String status) async {
    try {
      final success = await _updateData('maintenance_requests/$id', {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (success) {
        // 添加活動記錄
        await addActivity(
          'maintenance_request',
          '更新維修狀態',
          '維修請求狀態更新為：${_getStatusText(status)}',
          'admin',
          '管理員',
          metadata: {
            'request_id': id,
            'status': status,
          },
        );
      }
      
      return success;
    } catch (e) {
      print('Error updating maintenance request status: $e');
      return false;
    }
  }

  static String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待處理';
      case 'in_progress':
        return '處理中';
      case 'completed':
        return '已完成';
      default:
        return '未知';
    }
  }

  // 活動追蹤相關操作
  static Future<bool> addActivity(
    String type,
    String title,
    String description,
    String userId,
    String userName,
    {Map<String, dynamic>? metadata}
  ) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final success = await _setData('activities/$id', {
        'type': type,
        'title': title,
        'description': description,
        'user_id': userId,
        'user_name': userName,
        'created_at': DateTime.now().toIso8601String(),
        'metadata': metadata ?? {},
      });
      
      return success;
    } catch (e) {
      print('Error adding activity: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getRecentActivities({int limit = 10}) async {
    try {
      final data = await _getData('activities');
      if (data != null) {
        final activities = data.entries.map((entry) {
          final activityData = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key,
            'type': activityData['type']?.toString() ?? '',
            'title': activityData['title']?.toString() ?? '',
            'description': activityData['description']?.toString() ?? '',
            'user_id': activityData['user_id']?.toString() ?? '',
            'user_name': activityData['user_name']?.toString() ?? '',
            'created_at': activityData['created_at']?.toString() ?? '',
            'metadata': activityData['metadata'] ?? {},
          };
        }).toList();
        
        // 按時間排序（最新的在前）
        activities.sort((a, b) {
          final aTime = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1900);
          final bTime = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1900);
          return bTime.compareTo(aTime);
        });
        
        // 限制數量
        final limitedActivities = activities.take(limit).toList();
        
        return {
          'success': true,
          'activities': limitedActivities,
        };
      }
      return {'success': true, 'activities': []};
    } catch (e) {
      return {'success': false, 'message': '獲取活動列表失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // 獲取各種統計數據
      final usersData = await _getData('users');
      final invitationCodesData = await _getData('invitation_codes');
      final announcementsData = await _getData('announcements');
      final maintenanceRequestsData = await _getData('maintenance_requests');
      
      int totalUsers = 0;
      int totalResidents = 0;
      int validInvitationCodes = 0;
      int pendingMaintenanceRequests = 0;
      
      // 計算用戶統計
      if (usersData != null) {
        totalUsers = usersData.length;
        totalResidents = usersData.entries
            .where((entry) {
              final userData = entry.value as Map<dynamic, dynamic>;
              return userData['role']?.toString() == '住戶';
            })
            .length;
      }
      
      // 計算邀請碼統計
      if (invitationCodesData != null) {
        validInvitationCodes = invitationCodesData.entries
            .where((entry) {
              final codeData = entry.value as Map<dynamic, dynamic>;
              final isUsed = codeData['is_used'] ?? false;
              if (isUsed) return false;
              
              final expiresAtString = codeData['expires_at']?.toString();
              if (expiresAtString == null || expiresAtString.isEmpty) return false;
              
              try {
                final expiresAt = DateTime.parse(expiresAtString);
                return expiresAt.isAfter(DateTime.now());
              } catch (e) {
                return false;
              }
            })
            .length;
      }
      
      // 計算維修請求統計
      if (maintenanceRequestsData != null) {
        pendingMaintenanceRequests = maintenanceRequestsData.entries
            .where((entry) {
              final requestData = entry.value as Map<dynamic, dynamic>;
              return requestData['status']?.toString() == 'pending';
            })
            .length;
      }
      
      return {
        'success': true,
        'stats': {
          'total_users': totalUsers,
          'total_residents': totalResidents,
          'valid_invitation_codes': validInvitationCodes,
          'pending_maintenance_requests': pendingMaintenanceRequests,
          'total_announcements': announcementsData?.length ?? 0,
        },
      };
    } catch (e) {
      return {'success': false, 'message': '獲取統計數據失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> registerUser(
    String email,
    String password,
    String name,
    String role,
    String invitationCode,
  ) async {
    try {
      // 檢查邀請碼是否有效
      final invitationResult = await _getData('invitation_codes/$invitationCode');
      if (invitationResult == null) {
        return {'success': false, 'message': '邀請碼不存在'};
      }

      final invitationData = invitationResult as Map<dynamic, dynamic>;
      if (invitationData['is_used'] == true) {
        return {'success': false, 'message': '邀請碼已被使用'};
      }

      final expiresAtString = invitationData['expires_at']?.toString();
      if (expiresAtString != null && expiresAtString.isNotEmpty) {
        try {
          final expiresAt = DateTime.parse(expiresAtString);
          if (expiresAt.isBefore(DateTime.now())) {
            return {'success': false, 'message': '邀請碼已過期'};
          }
        } catch (e) {
          return {'success': false, 'message': '邀請碼格式錯誤'};
        }
      }

      // 創建用戶
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final success = await _setData('users/$userId', {
        'email': email,
        'name': name,
        'role': role,
        'invitation_code': invitationCode,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (success) {
        // 標記邀請碼為已使用
        await _updateData('invitation_codes/$invitationCode', {
          'is_used': true,
          'used_by': userId,
          'used_at': DateTime.now().toIso8601String(),
        });

        // 添加活動記錄
        await addActivity(
          'user_registration',
          '用戶註冊',
          '新用戶註冊：$name ($role)',
          userId,
          name,
          metadata: {
            'email': email,
            'role': role,
            'invitation_code': invitationCode,
          },
        );

        return {'success': true, 'message': '註冊成功'};
      } else {
        return {'success': false, 'message': '註冊失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '註冊失敗：$e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      // 獲取用戶信息用於活動記錄
      final userData = await _getData('users/$userId');
      String userName = '未知用戶';
      String userRole = '未知';
      
      if (userData != null) {
        final user = userData as Map<dynamic, dynamic>;
        userName = user['name']?.toString() ?? '未知用戶';
        userRole = user['role']?.toString() ?? '未知';
      }

      final success = await _deleteData('users/$userId');
      
      if (success) {
        // 添加活動記錄
        await addActivity(
          'user_deletion',
          '刪除用戶',
          '刪除用戶：$userName ($userRole)',
          'admin',
          '管理員',
          metadata: {
            'deleted_user_id': userId,
            'deleted_user_name': userName,
            'deleted_user_role': userRole,
          },
        );
        
        return {'success': true, 'message': '用戶刪除成功'};
      } else {
        return {'success': false, 'message': '刪除用戶失敗'};
      }
    } catch (e) {
      return {'success': false, 'message': '刪除用戶失敗：$e'};
    }
  }
} 