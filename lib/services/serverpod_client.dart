import 'dart:convert';
import 'package:http/http.dart' as http;

class ServerpodClientService {
  static const String baseUrl = 'http://localhost:8080';
  
  // 認證相關方法
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': '登入失敗'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': '連接失敗，請確認後端服務是否運行'};
    }
  }
  
  static Future<Map<String, dynamic>?> getUserInfo(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/getUserInfo?username=$username'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': '獲取用戶信息失敗'};
      }
    } catch (e) {
      print('Get user info error: $e');
      return {'success': false, 'message': '連接失敗'};
    }
  }
  
  static Future<Map<String, dynamic>?> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/getAllUsers'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': '獲取用戶列表失敗'};
      }
    } catch (e) {
      print('Get all users error: $e');
      return {'success': false, 'message': '連接失敗'};
    }
  }
  
  static Future<Map<String, dynamic>?> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/testConnection'),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': '連接測試失敗'};
      }
    } catch (e) {
      print('Test connection error: $e');
      return {'success': false, 'message': '無法連接到後端服務'};
    }
  }
} 