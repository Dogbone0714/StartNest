import 'package:mysql1/mysql1.dart';
import '../database_config.dart';
import '../models/user_model.dart';
import '../models/invitation_code_model.dart';

class DatabaseService {
  static Future<void> initializeDatabase() async {
    final connection = await DatabaseConfig.getConnection();
    try {
      // 創建用戶表
      await connection.query('''
        CREATE TABLE IF NOT EXISTS users (
          id INT AUTO_INCREMENT PRIMARY KEY,
          username VARCHAR(50) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          name VARCHAR(100) NOT NULL,
          role VARCHAR(20) NOT NULL,
          building VARCHAR(50) NOT NULL,
          unit VARCHAR(50) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
      ''');

      // 創建邀請碼表
      await connection.query('''
        CREATE TABLE IF NOT EXISTS invitation_codes (
          id INT AUTO_INCREMENT PRIMARY KEY,
          code VARCHAR(20) UNIQUE NOT NULL,
          created_by VARCHAR(50) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          expires_at TIMESTAMP NOT NULL,
          is_used BOOLEAN DEFAULT FALSE,
          used_by VARCHAR(50) NULL,
          used_at TIMESTAMP NULL,
          unit VARCHAR(50) NULL
        )
      ''');

      // 插入默認管理員用戶
      await connection.query('''
        INSERT IGNORE INTO users (username, password, name, role, building, unit)
        VALUES ('admin', 'buildings56119', '管理員', '管理員', '子敬園', '管理室')
      ''');

      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  // 用戶相關操作
  static Future<UserModel?> getUserByUsername(String username) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      final results = await connection.query(
        'SELECT * FROM users WHERE username = ?',
        [username],
      );

      if (results.isNotEmpty) {
        final row = results.first;
        return UserModel.fromMap({
          'id': row['id'],
          'username': row['username'],
          'password': row['password'],
          'name': row['name'],
          'role': row['role'],
          'building': row['building'],
          'unit': row['unit'],
          'created_at': row['created_at'].toString(),
          'updated_at': row['updated_at'].toString(),
        });
      }
      return null;
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<List<UserModel>> getAllUsers() async {
    final connection = await DatabaseConfig.getConnection();
    try {
      final results = await connection.query('SELECT * FROM users ORDER BY created_at DESC');
      
      return results.map((row) => UserModel.fromMap({
        'id': row['id'],
        'username': row['username'],
        'password': row['password'],
        'name': row['name'],
        'role': row['role'],
        'building': row['building'],
        'unit': row['unit'],
        'created_at': row['created_at'].toString(),
        'updated_at': row['updated_at'].toString(),
      })).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<List<UserModel>> getAllResidents() async {
    final connection = await DatabaseConfig.getConnection();
    try {
      final results = await connection.query(
        'SELECT * FROM users WHERE role = ? ORDER BY created_at DESC',
        ['住戶'],
      );
      
      return results.map((row) => UserModel.fromMap({
        'id': row['id'],
        'username': row['username'],
        'password': row['password'],
        'name': row['name'],
        'role': row['role'],
        'building': row['building'],
        'unit': row['unit'],
        'created_at': row['created_at'].toString(),
        'updated_at': row['updated_at'].toString(),
      })).toList();
    } catch (e) {
      print('Error getting all residents: $e');
      return [];
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<bool> createUser(UserModel user) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      await connection.query(
        'INSERT INTO users (username, password, name, role, building, unit) VALUES (?, ?, ?, ?, ?, ?)',
        [user.username, user.password, user.name, user.role, user.building, user.unit],
      );
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<bool> updateUser(String username, String name, String unit) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      await connection.query(
        'UPDATE users SET name = ?, unit = ? WHERE username = ?',
        [name, unit, username],
      );
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<bool> deleteUser(String username) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      await connection.query(
        'DELETE FROM users WHERE username = ? AND role != ?',
        [username, '管理員'],
      );
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  // 邀請碼相關操作
  static Future<List<InvitationCodeModel>> getAllInvitationCodes() async {
    final connection = await DatabaseConfig.getConnection();
    try {
      final results = await connection.query(
        'SELECT * FROM invitation_codes ORDER BY created_at DESC',
      );
      
      return results.map((row) => InvitationCodeModel.fromMap({
        'id': row['id'],
        'code': row['code'],
        'created_by': row['created_by'],
        'created_at': row['created_at'].toString(),
        'expires_at': row['expires_at'].toString(),
        'is_used': row['is_used'],
        'used_by': row['used_by'],
        'used_at': row['used_at']?.toString(),
        'unit': row['unit'],
      })).toList();
    } catch (e) {
      print('Error getting all invitation codes: $e');
      return [];
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<InvitationCodeModel?> getInvitationCodeByCode(String code) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      final results = await connection.query(
        'SELECT * FROM invitation_codes WHERE code = ?',
        [code],
      );

      if (results.isNotEmpty) {
        final row = results.first;
        return InvitationCodeModel.fromMap({
          'id': row['id'],
          'code': row['code'],
          'created_by': row['created_by'],
          'created_at': row['created_at'].toString(),
          'expires_at': row['expires_at'].toString(),
          'is_used': row['is_used'],
          'used_by': row['used_by'],
          'used_at': row['used_at']?.toString(),
          'unit': row['unit'],
        });
      }
      return null;
    } catch (e) {
      print('Error getting invitation code by code: $e');
      return null;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<bool> createInvitationCode(InvitationCodeModel code) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      await connection.query(
        'INSERT INTO invitation_codes (code, created_by, expires_at, unit) VALUES (?, ?, ?, ?)',
        [code.code, code.createdBy, code.expiresAt, code.unit],
      );
      return true;
    } catch (e) {
      print('Error creating invitation code: $e');
      return false;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<bool> useInvitationCode(String code, String username) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      await connection.query(
        'UPDATE invitation_codes SET is_used = TRUE, used_by = ?, used_at = NOW() WHERE code = ?',
        [username, code],
      );
      return true;
    } catch (e) {
      print('Error using invitation code: $e');
      return false;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }

  static Future<bool> deleteInvitationCode(String code) async {
    final connection = await DatabaseConfig.getConnection();
    try {
      await connection.query(
        'DELETE FROM invitation_codes WHERE code = ? AND is_used = FALSE',
        [code],
      );
      return true;
    } catch (e) {
      print('Error deleting invitation code: $e');
      return false;
    } finally {
      await DatabaseConfig.closeConnection(connection);
    }
  }
} 