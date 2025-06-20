class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String category; // 一般、重要、緊急、維護
  final List<String> targetBuildings; // 目標棟別
  final List<String> targetFloors; // 目標樓層
  final List<String> attachments; // 附件檔案
  final bool isPinned;
  final bool isRead;
  final int readCount;
  final List<String> readBy; // 已讀用戶ID列表

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    required this.category,
    required this.targetBuildings,
    required this.targetFloors,
    required this.attachments,
    required this.isPinned,
    this.isRead = false,
    this.readCount = 0,
    required this.readBy,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      category: json['category'] as String,
      targetBuildings: List<String>.from(json['targetBuildings'] as List),
      targetFloors: List<String>.from(json['targetFloors'] as List),
      attachments: List<String>.from(json['attachments'] as List),
      isPinned: json['isPinned'] as bool,
      isRead: json['isRead'] as bool? ?? false,
      readCount: json['readCount'] as int? ?? 0,
      readBy: List<String>.from(json['readBy'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'category': category,
      'targetBuildings': targetBuildings,
      'targetFloors': targetFloors,
      'attachments': attachments,
      'isPinned': isPinned,
      'isRead': isRead,
      'readCount': readCount,
      'readBy': readBy,
    };
  }

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
} 