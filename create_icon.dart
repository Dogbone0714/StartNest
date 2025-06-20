import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  // 創建一個簡單的圖示
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // 繪製綠色圓形背景
  final paint = Paint()
    ..color = const Color(0xFF4CAF50)
    ..style = PaintingStyle.fill;
  
  canvas.drawCircle(const Offset(512, 512), 512, paint);
  
  // 繪製建築物
  final buildingPaint = Paint()
    ..color = const Color(0xFF2E7D32)
    ..style = PaintingStyle.fill;
  
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(300, 400, 424, 300),
      const Radius.circular(20),
    ),
    buildingPaint,
  );
  
  // 繪製文字
  final textPainter = TextPainter(
    text: const TextSpan(
      text: '子敬園',
      style: TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  
  textPainter.layout();
  textPainter.paint(canvas, const Offset(400, 750));
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  
  // 寫入文件
  final file = File('assets/icons/app_icon_1024.png');
  await file.writeAsBytes(bytes);
  
  print('圖示已生成到: ${file.path}');
} 