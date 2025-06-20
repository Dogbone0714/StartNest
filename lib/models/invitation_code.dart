class InvitationCode {
  final String code;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isUsed;
  final String? usedBy;
  final DateTime? usedAt;
  final String? unit; // 預設房號（可選）

  InvitationCode({
    required this.code,
    required this.createdBy,
    required this.createdAt,
    this.expiresAt,
    this.isUsed = false,
    this.usedBy,
    this.usedAt,
    this.unit,
  });

  factory InvitationCode.fromMap(Map<String, dynamic> map) {
    return InvitationCode(
      code: map['code'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      isUsed: map['isUsed'] ?? false,
      usedBy: map['usedBy'],
      usedAt: map['usedAt'] != null ? DateTime.parse(map['usedAt']) : null,
      unit: map['unit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isUsed': isUsed,
      'usedBy': usedBy,
      'usedAt': usedAt?.toIso8601String(),
      'unit': unit,
    };
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isValid => !isUsed && !isExpired;

  @override
  String toString() {
    return 'InvitationCode(code: $code, createdBy: $createdBy, isUsed: $isUsed, isValid: $isValid)';
  }
} 