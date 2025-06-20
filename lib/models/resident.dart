class Resident {
  final String username;
  final String name;
  final String role;
  final String building;
  final String unit;

  Resident({
    required this.username,
    required this.name,
    required this.role,
    required this.building,
    required this.unit,
  });

  factory Resident.fromMap(Map<String, dynamic> map) {
    return Resident(
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      building: map['building'] ?? '',
      unit: map['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'name': name,
      'role': role,
      'building': building,
      'unit': unit,
    };
  }

  @override
  String toString() {
    return 'Resident(username: $username, name: $name, role: $role, building: $building, unit: $unit)';
  }
} 