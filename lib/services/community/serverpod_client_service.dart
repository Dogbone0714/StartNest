import 'package:community_garden_server_client/community_garden_server_client.dart';

class ServerpodClientService {
  static late Client _client;
  
  // 初始化客戶端
  static void initializeClient(String serverUrl) {
    _client = Client(serverUrl);
  }
  
  // 獲取客戶端實例
  static Client get client => _client;

  /// 用戶登入
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final result = await _client.auth.login(username: username, password: password);
      return result;
    } catch (e) {
      return {'success': false, 'message': '登入失敗：$e'};
    }
  }

  /// 獲取用戶信息
  static Future<Map<String, dynamic>?> getUserInfo(String username) async {
    try {
      final result = await _client.auth.getUserInfo(username: username);
      return result;
    } catch (e) {
      return {'success': false, 'message': '獲取用戶信息失敗：$e'};
    }
  }

  /// 獲取所有用戶列表
  static Future<Map<String, dynamic>?> getAllUsers() async {
    try {
      final result = await _client.auth.getAllUsers();
      return result;
    } catch (e) {
      return {'success': false, 'message': '獲取用戶列表失敗：$e'};
    }
  }

  /// 獲取所有住戶列表
  static Future<Map<String, dynamic>?> getAllResidents() async {
    try {
      final result = await _client.auth.getAllResidents();
      return result;
    } catch (e) {
      return {'success': false, 'message': '獲取住戶列表失敗：$e'};
    }
  }

  /// 新增住戶
  static Future<Map<String, dynamic>> addResident(
    String username,
    String password,
    String name,
    String unit,
  ) async {
    try {
      final result = await _client.auth.addResident(
        username: username,
        password: password,
        name: name,
        unit: unit,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': '新增住戶失敗：$e'};
    }
  }

  /// 刪除住戶
  static Future<Map<String, dynamic>> deleteResident(String username) async {
    try {
      final result = await _client.auth.deleteResident(username: username);
      return result;
    } catch (e) {
      return {'success': false, 'message': '刪除住戶失敗：$e'};
    }
  }

  /// 修改住戶信息
  static Future<Map<String, dynamic>> updateResidentInfo(
    String username,
    String name,
    String unit,
  ) async {
    try {
      final result = await _client.auth.updateResidentInfo(
        username: username,
        name: name,
        unit: unit,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': '更新住戶信息失敗：$e'};
    }
  }

  /// 生成邀請碼
  static Future<Map<String, dynamic>> generateInvitationCode(
    String createdBy, {
    int? validDays,
    String? unit,
  }) async {
    try {
      final result = await _client.auth.generateInvitationCode(
        createdBy: createdBy,
        validDays: validDays,
        unit: unit,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': '生成邀請碼失敗：$e'};
    }
  }

  /// 獲取所有邀請碼列表
  static Future<Map<String, dynamic>> getAllInvitationCodes() async {
    try {
      final result = await _client.auth.getAllInvitationCodes();
      return result;
    } catch (e) {
      return {'success': false, 'message': '獲取邀請碼列表失敗：$e'};
    }
  }

  /// 刪除邀請碼
  static Future<Map<String, dynamic>> deleteInvitationCode(String code) async {
    try {
      final result = await _client.auth.deleteInvitationCode(code: code);
      return result;
    } catch (e) {
      return {'success': false, 'message': '刪除邀請碼失敗：$e'};
    }
  }

  /// 驗證邀請碼
  static Future<Map<String, dynamic>> validateInvitationCode(String code) async {
    try {
      final result = await _client.auth.validateInvitationCode(code: code);
      return result;
    } catch (e) {
      return {'success': false, 'message': '驗證邀請碼失敗：$e'};
    }
  }

  /// 使用邀請碼
  static Future<Map<String, dynamic>> useInvitationCode(String code, String username) async {
    try {
      final result = await _client.auth.useInvitationCode(code: code, username: username);
      return result;
    } catch (e) {
      return {'success': false, 'message': '使用邀請碼失敗：$e'};
    }
  }

  /// 註冊用戶
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
    String name,
    String role,
    String building,
    String unit,
  ) async {
    try {
      final result = await _client.auth.register(
        username: username,
        password: password,
        name: name,
        role: role,
        building: building,
        unit: unit,
      );
      return result;
    } catch (e) {
      return {'success': false, 'message': '註冊失敗：$e'};
    }
  }

  /// 使用邀請碼註冊
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
      return {'success': false, 'message': '使用邀請碼註冊失敗：$e'};
    }
  }

  /// 測試連接
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final result = await _client.auth.testConnection();
      return result;
    } catch (e) {
      return {'success': false, 'message': '測試連接失敗：$e'};
    }
  }

  // ===== 社區管理相關API =====

  /// 獲取所有公告列表
  static Future<Map<String, dynamic>> getAllAnnouncements() async {
    try {
      // TODO: 實作公告API
      return {
        'success': true,
        'announcements': [
          {
            'id': 1,
            'title': '電梯維護通知',
            'content': 'A棟電梯將於明日進行維護，請住戶注意。',
            'createdBy': 'admin',
            'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
            'isImportant': true,
          },
          {
            'id': 2,
            'title': '社區清潔日',
            'content': '本週六將進行社區大掃除，請住戶配合。',
            'createdBy': 'admin',
            'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'isImportant': false,
          },
        ],
      };
    } catch (e) {
      return {'success': false, 'message': '獲取公告列表失敗：$e'};
    }
  }

  /// 新增公告
  static Future<Map<String, dynamic>> addAnnouncement(
    String title,
    String content,
    String createdBy, {
    bool isImportant = false,
  }) async {
    try {
      // TODO: 實作新增公告API
      return {'success': true, 'message': '公告發布成功'};
    } catch (e) {
      return {'success': false, 'message': '發布公告失敗：$e'};
    }
  }

  /// 刪除公告
  static Future<Map<String, dynamic>> deleteAnnouncement(int id) async {
    try {
      // TODO: 實作刪除公告API
      return {'success': true, 'message': '公告刪除成功'};
    } catch (e) {
      return {'success': false, 'message': '刪除公告失敗：$e'};
    }
  }

  /// 獲取所有維修單列表
  static Future<Map<String, dynamic>> getAllMaintenanceRequests() async {
    try {
      // TODO: 實作維修單API
      return {
        'success': true,
        'maintenanceRequests': [
          {
            'id': 1,
            'title': '水龍頭漏水',
            'description': '廚房水龍頭有漏水現象',
            'status': '處理中',
            'priority': '中',
            'createdBy': 'dogbone0714',
            'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'unit': '56-6號7樓',
          },
          {
            'id': 2,
            'title': '電燈故障',
            'description': '客廳電燈無法開啟',
            'status': '待處理',
            'priority': '高',
            'createdBy': 'resident2',
            'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            'unit': '119-2號2樓',
          },
        ],
      };
    } catch (e) {
      return {'success': false, 'message': '獲取維修單列表失敗：$e'};
    }
  }

  /// 新增維修單
  static Future<Map<String, dynamic>> addMaintenanceRequest(
    String title,
    String description,
    String createdBy,
    String unit, {
    String priority = '中',
  }) async {
    try {
      // TODO: 實作新增維修單API
      return {'success': true, 'message': '維修申請提交成功'};
    } catch (e) {
      return {'success': false, 'message': '提交維修申請失敗：$e'};
    }
  }

  /// 更新維修單狀態
  static Future<Map<String, dynamic>> updateMaintenanceRequestStatus(
    int id,
    String status,
  ) async {
    try {
      // TODO: 實作更新維修單狀態API
      return {'success': true, 'message': '維修單狀態更新成功'};
    } catch (e) {
      return {'success': false, 'message': '更新維修單狀態失敗：$e'};
    }
  }

  /// 獲取統計資料
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      // TODO: 實作統計資料API
      return {
        'success': true,
        'statistics': {
          'totalResidents': 156,
          'pendingMaintenance': 8,
          'activeInvitationCodes': 5,
        },
      };
    } catch (e) {
      return {'success': false, 'message': '獲取統計資料失敗：$e'};
    }
  }
} 