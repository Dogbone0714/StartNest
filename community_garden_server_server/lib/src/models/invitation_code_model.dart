class InvitationCodeModel {
  final int? id;
  final String code;
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;
  final String? usedBy;
  final DateTime? usedAt;
  final String? unit;

  InvitationCodeModel({
    this.id,
    required this.code,
    required this.createdBy,
    required this.createdAt,
    required this.expiresAt,
    required this.isUsed,
    this.usedBy,
    this.usedAt,
    this.unit,
  });

  factory InvitationCodeModel.fromMap(Map<String, dynamic> map) {
    return InvitationCodeModel(
      id: map['id'],
      code: map['code'] ?? '',
      createdBy: map['created_by'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      expiresAt: DateTime.parse(map['expires_at']),
      isUsed: map['is_used'] == 1 || map['is_used'] == true,
      usedBy: map['used_by'],
      usedAt: map['used_at'] != null ? DateTime.parse(map['used_at']) : null,
      unit: map['unit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_used': isUsed ? 1 : 0,
      'used_by': usedBy,
      'used_at': usedAt?.toIso8601String(),
      'unit': unit,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && !isUsed;
} 