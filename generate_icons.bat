@echo off
echo 正在生成子敬園圖示...

echo 1. 獲取依賴...
flutter pub get

echo 2. 生成圖示...
flutter pub run flutter_launcher_icons:main

echo 3. 清理緩存...
flutter clean
flutter pub get

echo 圖示生成完成！
echo 請確保已創建 assets/icons/app_icon_1024.png 文件
pause 