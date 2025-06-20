# 子敬園圖示生成說明

## 步驟：
1. 將 `app_icon.svg` 文件轉換為 `app_icon_1024.png`（1024x1024像素）
2. 可以使用以下工具：
   - 在線SVG轉PNG工具
   - Inkscape（免費開源）
   - Adobe Illustrator
   - 其他圖像編輯軟件

## 圖示要求：
- 尺寸：1024x1024像素
- 格式：PNG
- 背景：透明或綠色圓形背景
- 內容：子敬園建築物和園林設計

## 生成圖示後：
運行以下命令生成各平台圖示：
```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

這將自動生成Android、iOS和Web平台的圖示。 