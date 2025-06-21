import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await injectAdminToFirebase();
}

Future<void> injectAdminToFirebase() async {
  const String baseUrl = 'https://community-buildings56119-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  // 管理員資料
  final adminData = {
    'username': 'admin',
    'password': 'buildings56119',
    'name': '管理員',
    'role': '管理員',
    'building': '子敬園',
    'unit': '管理室',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  try {
    print('🔄 正在注入管理員資料到 Firebase...');
    
    // 檢查是否已存在管理員帳號
    final checkResponse = await http.get(
      Uri.parse('$baseUrl/users/admin.json'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (checkResponse.statusCode == 200) {
      final existingData = json.decode(checkResponse.body);
      if (existingData != null) {
        print('⚠️ 管理員帳號已存在，正在更新...');
      }
    }
    
    // 注入管理員資料
    final response = await http.put(
      Uri.parse('$baseUrl/users/admin.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(adminData),
    );
    
    if (response.statusCode == 200) {
      print('✅ 管理員資料注入成功！');
      print('📋 管理員帳號信息：');
      print('   帳號: admin');
      print('   密碼: buildings56119');
      print('   姓名: 管理員');
      print('   角色: 管理員');
      print('   建築: 子敬園');
      print('   單位: 管理室');
      
      // 驗證注入是否成功
      final verifyResponse = await http.get(
        Uri.parse('$baseUrl/users/admin.json'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (verifyResponse.statusCode == 200) {
        final verifyData = json.decode(verifyResponse.body);
        if (verifyData != null) {
          print('✅ 驗證成功：管理員資料已正確存儲在 Firebase 中');
        } else {
          print('❌ 驗證失敗：無法讀取管理員資料');
        }
      } else {
        print('❌ 驗證失敗：HTTP ${verifyResponse.statusCode}');
      }
    } else {
      print('❌ 注入失敗：HTTP ${response.statusCode}');
      print('錯誤信息：${response.body}');
    }
  } catch (e) {
    print('❌ 注入失敗：$e');
  }
} 