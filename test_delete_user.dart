import 'dart:async';
import 'lib/services/community/serverpod_client_service.dart';

void main() async {
  print('測試刪除用戶功能...');
  
  // 初始化客戶端
  ServerpodClientService.initializeClient('http://localhost:8080/');
  
  try {
    // 測試連接
    print('1. 測試後端連接...');
    final connectionResult = await ServerpodClientService.testConnection();
    print('連接結果: $connectionResult');
    
    if (connectionResult != null && connectionResult['success'] == true) {
      print('✓ 後端連接成功');
      
      // 測試獲取住戶列表
      print('\n2. 測試獲取住戶列表...');
      final residentsResult = await ServerpodClientService.getAllResidents();
      print('住戶列表結果: $residentsResult');
      
      if (residentsResult != null && residentsResult['success'] == true) {
        final residents = residentsResult['residents'] as List;
        print('✓ 成功獲取 ${residents.length} 個住戶');
        
        if (residents.isNotEmpty) {
          // 測試刪除第一個住戶
          final firstResident = residents.first;
          final username = firstResident['username'];
          
          print('\n3. 測試刪除住戶: $username');
          final deleteResult = await ServerpodClientService.deleteResident(username);
          print('刪除結果: $deleteResult');
          
          if (deleteResult['success'] == true) {
            print('✓ 成功刪除住戶: $username');
            
            // 再次獲取住戶列表確認刪除
            print('\n4. 確認刪除結果...');
            final newResidentsResult = await ServerpodClientService.getAllResidents();
            if (newResidentsResult != null && newResidentsResult['success'] == true) {
              final newResidents = newResidentsResult['residents'] as List;
              print('刪除後剩餘住戶數量: ${newResidents.length}');
              
              final deletedUserExists = newResidents.any((r) => r['username'] == username);
              if (!deletedUserExists) {
                print('✓ 確認用戶已從資料庫中刪除');
              } else {
                print('✗ 用戶仍然存在於資料庫中');
              }
            }
          } else {
            print('✗ 刪除住戶失敗: ${deleteResult['message']}');
          }
        } else {
          print('沒有住戶可以刪除');
        }
      } else {
        print('✗ 獲取住戶列表失敗: ${residentsResult?['message'] ?? '未知錯誤'}');
      }
    } else {
      print('✗ 後端連接失敗: ${connectionResult?['message'] ?? '未知錯誤'}');
    }
  } catch (e) {
    print('✗ 測試過程中發生錯誤: $e');
  }
  
  print('\n測試完成');
} 