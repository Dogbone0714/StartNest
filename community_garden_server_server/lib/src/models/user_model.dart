class UserModel {
  final int? id;
  final String username;
  final String password;
  final String name;
  final String role;
  final String building;
  final String unit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.building,
    required this.unit,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      building: map['building'] ?? '',
      unit: map['unit'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'role': role,
      'building': building,
      'unit': unit,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapWithoutPassword() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'building': building,
      'unit': unit,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 