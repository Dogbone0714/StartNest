import 'package:serverpod/serverpod.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../models/invitation_code_model.dart';

class AuthEndpoint extends Endpoint {
  @override
  String get name => 'auth';

  @override
  Future<void> startup() async {
    // 初始化 Firebase 資料庫
    await FirebaseService.initializeFirebase();
  }

  /// 用戶登入
  Future<Map<String, dynamic>> login(
    Session session, {
    required String username,
    required String password,
  }) async {
    try {
      final user = await FirebaseService.getUserByUsername(username);
      
      if (user != null && user.password == password) {
        return {
          'success': true,
          'user': user.toMapWithoutPassword(),
        };
      }
      
      return {'success': false, 'message': '帳號或密碼錯誤'};
    } catch (e) {
      session.log('Login error: $e');
      return {'success': false, 'message': '登入失敗'};
    }
  }

  /// 獲取用戶信息
  Future<Map<String, dynamic>> getUserInfo(
    Session session, {
    required String username,
  }) async {
    try {
      final user = await FirebaseService.getUserByUsername(username);
      
      if (user != null) {
        return {
          'success': true,
          'user': user.toMapWithoutPassword(),
        };
      }
      
      return {'success': false, 'message': '用戶不存在'};
    } catch (e) {
      session.log('Get user info error: $e');
      return {'success': false, 'message': '獲取用戶信息失敗'};
    }
  }

  /// 獲取所有用戶列表
  Future<Map<String, dynamic>> getAllUsers(Session session) async {
    try {
      final users = await FirebaseService.getAllUsers();
      final userMaps = users.map((user) => user.toMapWithoutPassword()).toList();
      
      return {
        'success': true,
        'users': userMaps,
      };
    } catch (e) {
      session.log('Get all users error: $e');
      return {'success': false, 'message': '獲取用戶列表失敗'};
    }
  }

  /// 獲取所有住戶列表
  Future<Map<String, dynamic>> getAllResidents(Session session) async {
    try {
      final residents = await FirebaseService.getAllResidents();
      final residentMaps = residents.map((user) => user.toMapWithoutPassword()).toList();
      
      return {
        'success': true,
        'residents': residentMaps,
      };
    } catch (e) {
      session.log('Get all residents error: $e');
      return {'success': false, 'message': '獲取住戶列表失敗'};
    }
  }

  /// 新增住戶
  Future<Map<String, dynamic>> addResident(
    Session session, {
    required String username,
    required String password,
    required String name,
    required String unit,
  }) async {
    try {
      // 檢查用戶名是否已存在
      final existingUser = await FirebaseService.getUserByUsername(username);
      if (existingUser != null) {
        return {'success': false, 'message': '用戶名已存在'};
      }

      final user = UserModel(
        username: username,
        password: password,
        name: name,
        role: '住戶',
        building: '子敬園',
        unit: unit,
      );

      final success = await FirebaseService.createUser(user);
      
      if (success) {
        return {'success': true, 'message': '住戶新增成功'};
      } else {
        return {'success': false, 'message': '新增住戶失敗'};
      }
    } catch (e) {
      session.log('Add resident error: $e');
      return {'success': false, 'message': '新增住戶失敗'};
    }
  }

  /// 刪除住戶
  Future<Map<String, dynamic>> deleteResident(
    Session session, {
    required String username,
  }) async {
    try {
      if (username == 'admin') {
        return {'success': false, 'message': '管理員帳號不可刪除'};
      }

      final success = await FirebaseService.deleteUser(username);
      
      if (success) {
        return {'success': true, 'message': '住戶刪除成功'};
      } else {
        return {'success': false, 'message': '刪除住戶失敗'};
      }
    } catch (e) {
      session.log('Delete resident error: $e');
      return {'success': false, 'message': '刪除住戶失敗'};
    }
  }

  /// 修改住戶信息
  Future<Map<String, dynamic>> updateResidentInfo(
    Session session, {
    required String username,
    required String name,
    required String unit,
  }) async {
    try {
      final success = await FirebaseService.updateUser(username, name, unit);
      
      if (success) {
        return {'success': true, 'message': '住戶信息更新成功'};
      } else {
        return {'success': false, 'message': '更新住戶信息失敗'};
      }
    } catch (e) {
      session.log('Update resident info error: $e');
      return {'success': false, 'message': '更新住戶信息失敗'};
    }
  }

  /// 生成邀請碼
  Future<Map<String, dynamic>> generateInvitationCode(
    Session session, {
    required String createdBy,
    int? validDays,
    String? unit,
  }) async {
    try {
      final code = 'ABC${DateTime.now().millisecondsSinceEpoch % 1000}';
      final expiresAt = DateTime.now().add(Duration(days: validDays ?? 7));
      
      final invitationCode = InvitationCodeModel(
        code: code,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        isUsed: false,
        unit: unit,
      );

      final success = await FirebaseService.createInvitationCode(invitationCode);
      
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
      session.log('Generate invitation code error: $e');
      return {'success': false, 'message': '生成邀請碼失敗'};
    }
  }

  /// 獲取所有邀請碼列表
  Future<Map<String, dynamic>> getAllInvitationCodes(Session session) async {
    try {
      final codes = await FirebaseService.getAllInvitationCodes();
      final codeMaps = codes.map((code) => code.toMap()).toList();
      
      return {
        'success': true,
        'codes': codeMaps,
      };
    } catch (e) {
      session.log('Get all invitation codes error: $e');
      return {'success': false, 'message': '獲取邀請碼列表失敗'};
    }
  }

  /// 刪除邀請碼
  Future<Map<String, dynamic>> deleteInvitationCode(
    Session session, {
    required String code,
  }) async {
    try {
      final success = await FirebaseService.deleteInvitationCode(code);
      
      if (success) {
        return {'success': true, 'message': '邀請碼刪除成功'};
      } else {
        return {'success': false, 'message': '刪除邀請碼失敗'};
      }
    } catch (e) {
      session.log('Delete invitation code error: $e');
      return {'success': false, 'message': '刪除邀請碼失敗'};
    }
  }

  /// 驗證邀請碼
  Future<Map<String, dynamic>> validateInvitationCode(
    Session session, {
    required String code,
  }) async {
    try {
      final invitationCode = await FirebaseService.getInvitationCode(code);
      
      if (invitationCode == null) {
        return {'success': false, 'message': '邀請碼不存在'};
      }
      
      if (invitationCode.isUsed) {
        return {'success': false, 'message': '邀請碼已被使用'};
      }
      
      if (invitationCode.expiresAt.isBefore(DateTime.now())) {
        return {'success': false, 'message': '邀請碼已過期'};
      }
      
      return {
        'success': true,
        'message': '邀請碼有效',
        'code': invitationCode.toMap(),
      };
    } catch (e) {
      session.log('Validate invitation code error: $e');
      return {'success': false, 'message': '驗證邀請碼失敗'};
    }
  }

  /// 使用邀請碼
  Future<Map<String, dynamic>> useInvitationCode(
    Session session, {
    required String code,
    required String username,
  }) async {
    try {
      final success = await FirebaseService.useInvitationCode(code, username);
      
      if (success) {
        return {'success': true, 'message': '邀請碼使用成功'};
      } else {
        return {'success': false, 'message': '使用邀請碼失敗'};
      }
    } catch (e) {
      session.log('Use invitation code error: $e');
      return {'success': false, 'message': '使用邀請碼失敗'};
    }
  }

  /// 註冊用戶
  Future<Map<String, dynamic>> register(
    Session session, {
    required String username,
    required String password,
    required String name,
    required String role,
    required String building,
    required String unit,
  }) async {
    try {
      // 檢查用戶名是否已存在
      final existingUser = await FirebaseService.getUserByUsername(username);
      if (existingUser != null) {
        return {'success': false, 'message': '用戶名已存在'};
      }

      final user = UserModel(
        username: username,
        password: password,
        name: name,
        role: role,
        building: building,
        unit: unit,
      );

      final success = await FirebaseService.createUser(user);
      
      if (success) {
        return {'success': true, 'message': '註冊成功'};
      } else {
        return {'success': false, 'message': '註冊失敗'};
      }
    } catch (e) {
      session.log('Register error: $e');
      return {'success': false, 'message': '註冊失敗'};
    }
  }

  /// 測試連接
  Future<Map<String, dynamic>> testConnection(Session session) async {
    try {
      return {
        'success': true,
        'message': '子敬園一點通後端服務正常運行',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      session.log('Test connection error: $e');
      return {'success': false, 'message': '服務連接失敗'};
    }
  }
} 