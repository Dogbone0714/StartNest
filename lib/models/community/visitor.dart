import 'package:flutter/material.dart';

class Visitor {
  final String id;
  final String residentId;
  final String residentName;
  final String visitorName;
  final String visitorPhone;
  final String visitorIdNumber;
  final String purpose;
  final DateTime visitDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status; // 已登記、已進入、已離開、已取消
  final String? qrCode;
  final String? notes;
  final List<String> companions; // 同行人數
  final String vehicleNumber; // 車牌號碼
  final String vehicleType; // 汽車、機車、腳踏車

  Visitor({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.visitorName,
    required this.visitorPhone,
    required this.visitorIdNumber,
    required this.purpose,
    required this.visitDate,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.qrCode,
    this.notes,
    required this.companions,
    required this.vehicleNumber,
    required this.vehicleType,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'] as String,
      residentId: json['residentId'] as String,
      residentName: json['residentName'] as String,
      visitorName: json['visitorName'] as String,
      visitorPhone: json['visitorPhone'] as String,
      visitorIdNumber: json['visitorIdNumber'] as String,
      purpose: json['purpose'] as String,
      visitDate: DateTime.parse(json['visitDate'] as String),
      checkInTime: json['checkInTime'] != null 
          ? DateTime.parse(json['checkInTime'] as String) 
          : null,
      checkOutTime: json['checkOutTime'] != null 
          ? DateTime.parse(json['checkOutTime'] as String) 
          : null,
      status: json['status'] as String,
      qrCode: json['qrCode'] as String?,
      notes: json['notes'] as String?,
      companions: List<String>.from(json['companions'] as List),
      vehicleNumber: json['vehicleNumber'] as String,
      vehicleType: json['vehicleType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residentId': residentId,
      'residentName': residentName,
      'visitorName': visitorName,
      'visitorPhone': visitorPhone,
      'visitorIdNumber': visitorIdNumber,
      'purpose': purpose,
      'visitDate': visitDate.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'status': status,
      'qrCode': qrCode,
      'notes': notes,
      'companions': companions,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(visitDate);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小時前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分鐘前';
    } else {
      return '剛剛';
    }
  }

  Color get statusColor {
    switch (status) {
      case '已登記':
        return Colors.blue;
      case '已進入':
        return Colors.green;
      case '已離開':
        return Colors.grey;
      case '已取消':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool get isActive => status == '已進入';
  bool get hasCheckedOut => status == '已離開';
} 