class AppConstants {
  // 應用名稱
  static const String appName = '子敬園一指通';
  
  // 用戶角色
  static const String roleResident = '住戶';
  static const String roleAdmin = '管理員';
  static const String roleSuperAdmin = '超級管理員';
  
  // 公告類別
  static const List<String> announcementCategories = [
    '一般',
    '重要',
    '緊急',
    '維護',
  ];
  
  // 維修類別
  static const List<String> maintenanceCategories = [
    '水電',
    '電梯',
    '門禁',
    '環境',
    '其他',
  ];
  
  // 優先級別
  static const List<String> priorityLevels = [
    '低',
    '中',
    '高',
    '緊急',
  ];
  
  // 狀態
  static const List<String> requestStatuses = [
    '待處理',
    '處理中',
    '已完成',
    '已取消',
  ];
  
  // 訪客狀態
  static const List<String> visitorStatuses = [
    '已登記',
    '已進入',
    '已離開',
    '已取消',
  ];
  
  // 車輛類型
  static const List<String> vehicleTypes = [
    '汽車',
    '機車',
    '腳踏車',
    '無',
  ];
  
  // 住戶類型
  static const List<String> residentTypes = [
    '業主',
    '租戶',
    '訪客',
  ];
  
  // 顏色配置
  static const int primaryColor = 0xFF2196F3;
  static const int secondaryColor = 0xFF1976D2;
  static const int accentColor = 0xFF03A9F4;
  
  // 字體大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeExtraLarge = 18.0;
  
  // 間距
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // 圓角
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
} 