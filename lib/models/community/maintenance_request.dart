import 'package:flutter/material.dart';

class MaintenanceRequest {
  final String id;
  final String residentId;
  final String residentName;
  final String unitNumber;
  final String buildingNumber;
  final String floorNumber;
  final String title;
  final String description;
  final String category; // 水電、電梯、門禁、環境、其他
  final String priority; // 低、中、高、緊急
  final String status; // 待處理、處理中、已完成、已取消
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? assignedTo;
  final String? assignedToName;
  final List<String> images;
  final String? notes;
  final double? estimatedCost;
  final double? actualCost;
  final String? completionNotes;

  MaintenanceRequest({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.unitNumber,
    required this.buildingNumber,
    required this.floorNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.scheduledDate,
    this.completedDate,
    this.assignedTo,
    this.assignedToName,
    required this.images,
    this.notes,
    this.estimatedCost,
    this.actualCost,
    this.completionNotes,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] as String,
      residentId: json['residentId'] as String,
      residentName: json['residentName'] as String,
      unitNumber: json['unitNumber'] as String,
      buildingNumber: json['buildingNumber'] as String,
      floorNumber: json['floorNumber'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      scheduledDate: json['scheduledDate'] != null 
          ? DateTime.parse(json['scheduledDate'] as String) 
          : null,
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'] as String) 
          : null,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      images: List<String>.from(json['images'] as List),
      notes: json['notes'] as String?,
      estimatedCost: json['estimatedCost'] as double?,
      actualCost: json['actualCost'] as double?,
      completionNotes: json['completionNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residentId': residentId,
      'residentName': residentName,
      'unitNumber': unitNumber,
      'buildingNumber': buildingNumber,
      'floorNumber': floorNumber,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'images': images,
      'notes': notes,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'completionNotes': completionNotes,
    };
  }

  String get fullAddress => '$buildingNumber棟$floorNumber樓$unitNumber號';

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
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

  Color get priorityColor {
    switch (priority) {
      case '緊急':
        return Colors.red;
      case '高':
        return Colors.orange;
      case '中':
        return Colors.yellow;
      case '低':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color get statusColor {
    switch (status) {
      case '待處理':
        return Colors.orange;
      case '處理中':
        return Colors.blue;
      case '已完成':
        return Colors.green;
      case '已取消':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 