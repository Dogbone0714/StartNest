class ServerpodClientService {
  /// 用戶登入
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      // 模拟API调用，实际应该调用client.auth.login
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 模拟用户数据
      final mockUsers = {
        'admin': {
          'password': 'buildings56119',
          'name': '管理員',
          'role': '管理員',
          'building': '子敬園',
          'unit': '管理室',
        },
        'dogbone0714': {
          'password': 'abc054015',
          'name': '康皓雄',
          'role': '住戶',
          'building': '子敬園',
          'unit': '5667',
        },
        'resident2': {
          'password': 'resident123',
          'name': '李小華',
          'role': '住戶',
          'building': '子敬園',
          'unit': '2202',
        },
        'resident3': {
          'password': 'resident123',
          'name': '王美玲',
          'role': '住戶',
          'building': '子敬園',
          'unit': '3303',
        },
      };

      if (mockUsers.containsKey(username) && 
          mockUsers[username]!['password'] == password) {
        final user = mockUsers[username]!;
        return {
          'success': true,
          'user': {
            'username': username,
            'name': user['name'],
            'role': user['role'],
            'building': user['building'],
            'unit': user['unit'],
          },
        };
      }
      return {'success': false, 'message': '帳號或密碼錯誤'};
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  /// 獲取用戶信息
  static Future<Map<String, dynamic>?> getUserInfo(String username) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockUsers = {
        'admin': {
          'password': 'buildings56119',
          'name': '管理員',
          'role': '管理員',
          'building': '子敬園',
          'unit': '管理室',
        },
        'dogbone0714': {
          'password': 'abc054015',
          'name': '康皓雄',
          'role': '住戶',
          'building': '子敬園',
          'unit': '5667',
        },
        'resident2': {
          'password': 'resident123',
          'name': '李小華',
          'role': '住戶',
          'building': '子敬園',
          'unit': '2202',
        },
        'resident3': {
          'password': 'resident123',
          'name': '王美玲',
          'role': '住戶',
          'building': '子敬園',
          'unit': '3303',
        },
      };

      if (mockUsers.containsKey(username)) {
        final user = mockUsers[username]!;
        return {
          'success': true,
          'user': {
            'username': username,
            'name': user['name'],
            'role': user['role'],
            'building': user['building'],
            'unit': user['unit'],
          },
        };
      }
      return {'success': false, 'message': '用戶不存在'};
    } catch (e) {
      print('Get user info error: $e');
      return null;
    }
  }

  /// 獲取所有用戶列表
  static Future<Map<String, dynamic>?> getAllUsers() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      final mockUsers = {
        'admin': {
          'password': 'buildings56119',
          'name': '管理員',
          'role': '管理員',
          'building': '子敬園',
          'unit': '管理室',
        },
        'dogbone0714': {
          'password': 'abc054015',
          'name': '康皓雄',
          'role': '住戶',
          'building': '子敬園',
          'unit': '5667',
        },
        'resident2': {
          'password': 'resident123',
          'name': '李小華',
          'role': '住戶',
          'building': '子敬園',
          'unit': '2202',
        },
        'resident3': {
          'password': 'resident123',
          'name': '王美玲',
          'role': '住戶',
          'building': '子敬園',
          'unit': '3303',
        },
      };

      final users = mockUsers.entries.map((entry) {
        final user = entry.value;
        return {
          'username': entry.key,
          'name': user['name'],
          'role': user['role'],
          'building': user['building'],
          'unit': user['unit'],
        };
      }).toList();

      return {
        'success': true,
        'users': users,
      };
    } catch (e) {
      print('Get all users error: $e');
      return null;
    }
  }

  /// 獲取所有住戶列表
  static Future<Map<String, dynamic>?> getAllResidents() async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      final mockUsers = {
        'admin': {
          'password': 'buildings56119',
          'name': '管理員',
          'role': '管理員',
          'building': '子敬園',
          'unit': '管理室',
        },
        'dogbone0714': {
          'password': 'abc054015',
          'name': '康皓雄',
          'role': '住戶',
          'building': '子敬園',
          'unit': '5667',
        },
        'resident2': {
          'password': 'resident123',
          'name': '李小華',
          'role': '住戶',
          'building': '子敬園',
          'unit': '2202',
        },
        'resident3': {
          'password': 'resident123',
          'name': '王美玲',
          'role': '住戶',
          'building': '子敬園',
          'unit': '3303',
        },
        'newuser123': {
          'password': 'newuser123',
          'name': '張小明',
          'role': '住戶',
          'building': '子敬園',
          'unit': '1101',
        },
      };

      final residents = mockUsers.entries
          .where((entry) => entry.value['role'] == '住戶')
          .map((entry) {
        final user = entry.value;
        return {
          'username': entry.key,
          'name': user['name'],
          'role': user['role'],
          'building': user['building'],
          'unit': user['unit'],
        };
      }).toList();

      return {
        'success': true,
        'residents': residents,
      };
    } catch (e) {
      print('Get all residents error: $e');
      return null;
    }
  }

  /// 測試連接
  static Future<Map<String, dynamic>?> testConnection() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'success': true,
        'message': '子敬園一點通後端服務正常運行',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Test connection error: $e');
      return null;
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
      await Future.delayed(const Duration(milliseconds: 600));
      
      // 模拟添加用户到内存存储
      return {'success': true, 'message': '住戶新增成功'};
    } catch (e) {
      print('Add resident error: $e');
      return {'success': false, 'message': '新增住戶失敗'};
    }
  }

  /// 刪除住戶
  static Future<Map<String, dynamic>> deleteResident(String username) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (username == 'admin') {
        return {'success': false, 'message': '管理員帳號不可刪除'};
      }
      
      return {'success': true, 'message': '住戶刪除成功'};
    } catch (e) {
      print('Delete resident error: $e');
      return {'success': false, 'message': '刪除住戶失敗'};
    }
  }

  /// 生成邀請碼
  static Future<Map<String, dynamic>> generateInvitationCode(
    String createdBy, {
    int? validDays,
    String? unit,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 模拟生成邀请码
      final code = 'ABC${DateTime.now().millisecondsSinceEpoch % 1000}';
      final expiresAt = DateTime.now().add(Duration(days: validDays ?? 7));
      
      return {
        'success': true,
        'message': '邀請碼生成成功',
        'code': code,
        'expiresAt': expiresAt.toIso8601String(),
      };
    } catch (e) {
      print('Generate invitation code error: $e');
      return {'success': false, 'message': '生成邀請碼失敗'};
    }
  }

  /// 獲取所有邀請碼列表
  static Future<Map<String, dynamic>> getAllInvitationCodes() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 模拟邀请码数据
      final codes = [
        {
          'code': 'ABC123',
          'createdBy': 'admin',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'expiresAt': DateTime.now().add(const Duration(days: 6)).toIso8601String(),
          'isUsed': false,
          'usedBy': null,
          'usedAt': null,
          'unit': '1101',
          'isExpired': false,
          'isValid': true,
        },
        {
          'code': 'DEF456',
          'createdBy': 'admin',
          'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          'expiresAt': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
          'isUsed': false,
          'usedBy': null,
          'usedAt': null,
          'unit': '2202',
          'isExpired': false,
          'isValid': true,
        },
        {
          'code': 'GHI789',
          'createdBy': 'admin',
          'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'expiresAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
          'isUsed': false,
          'usedBy': null,
          'usedAt': null,
          'unit': '3303',
          'isExpired': true,
          'isValid': false,
        },
        {
          'code': 'JKL012',
          'createdBy': 'admin',
          'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'expiresAt': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
          'isUsed': true,
          'usedBy': 'newuser123',
          'usedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'unit': '4404',
          'isExpired': false,
          'isValid': false,
        },
      ];

      return {
        'success': true,
        'codes': codes,
      };
    } catch (e) {
      print('Get all invitation codes error: $e');
      return {'success': false, 'message': '獲取邀請碼列表失敗'};
    }
  }

  /// 刪除邀請碼
  static Future<Map<String, dynamic>> deleteInvitationCode(String code) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      // 模拟删除邀请码
      return {'success': true, 'message': '邀請碼刪除成功'};
    } catch (e) {
      print('Delete invitation code error: $e');
      return {'success': false, 'message': '刪除邀請碼失敗'};
    }
  }

  /// 驗證邀請碼
  static Future<Map<String, dynamic>> validateInvitationCode(String code) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 模拟验证邀请码
      if (code == 'ABC123') {
        return {
          'success': true,
          'message': '邀請碼有效',
          'unit': '1101',
        };
      } else if (code == 'DEF456') {
        return {
          'success': true,
          'message': '邀請碼有效',
          'unit': '2202',
        };
      } else {
        return {'success': false, 'message': '邀請碼不存在或已過期'};
      }
    } catch (e) {
      print('Validate invitation code error: $e');
      return {'success': false, 'message': '驗證邀請碼失敗'};
    }
  }

  /// 使用邀請碼
  static Future<Map<String, dynamic>> useInvitationCode(String code, String username) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      // 模拟使用邀请码
      if (code == 'ABC123' || code == 'DEF456') {
        return {'success': true, 'message': '邀請碼使用成功'};
      } else {
        return {'success': false, 'message': '邀請碼無效或已使用'};
      }
    } catch (e) {
      print('Use invitation code error: $e');
      return {'success': false, 'message': '使用邀請碼失敗'};
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
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 模拟注册用户
      return {'success': true, 'message': '註冊成功'};
    } catch (e) {
      print('Register error: $e');
      return {'success': false, 'message': '註冊失敗'};
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
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // 模拟使用邀请码注册
      if (code == 'ABC123' || code == 'DEF456') {
        return {'success': true, 'message': '註冊成功'};
      } else {
        return {'success': false, 'message': '邀請碼無效'};
      }
    } catch (e) {
      print('Register with invitation code error: $e');
      return {'success': false, 'message': '註冊失敗'};
    }
  }

  /// 修改住戶信息
  static Future<Map<String, dynamic>> updateResidentInfo(
    String username,
    String name,
    String unit,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      // 模拟更新住戶信息
      return {'success': true, 'message': '住戶信息更新成功'};
    } catch (e) {
      print('Update resident info error: $e');
      return {'success': false, 'message': '更新住戶信息失敗'};
    }
  }
} 