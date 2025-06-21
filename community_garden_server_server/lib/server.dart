import 'package:serverpod/serverpod.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/services/firebase_service.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  // 初始化 Firebase 資料庫
  try {
    await FirebaseService.initializeFirebase();
    print('✅ Firebase 資料庫初始化成功');
  } catch (e) {
    print('❌ Firebase 資料庫初始化失敗: $e');
    return;
  }

  // Start the server.
  await pod.start();

  print('🚀 子敬園一點通後端服務已啟動');
  print('📍 服務地址: http://localhost:8080');
  print('🗄️ 資料庫: Firebase Realtime Database');
  print('🔐 管理員帳號: admin / buildings56119');
}

/// Names of all future calls in the server.
///
/// This is better than using a string literal, as it will reduce the risk of
/// typos and make it easier to refactor the code.
enum FutureCallNames {
  birthdayReminder,
}
