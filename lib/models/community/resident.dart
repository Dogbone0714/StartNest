class Resident {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String unitNumber;
  final String buildingNumber;
  final String floorNumber;
  final String residentType; // 業主、租戶、訪客
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final bool isActive;
  final String? profileImage;
  final List<String> familyMembers;
  final Map<String, dynamic> preferences;

  Resident({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.unitNumber,
    required this.buildingNumber,
    required this.floorNumber,
    required this.residentType,
    required this.moveInDate,
    this.moveOutDate,
    required this.isActive,
    this.profileImage,
    required this.familyMembers,
    required this.preferences,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      unitNumber: json['unitNumber'] as String,
      buildingNumber: json['buildingNumber'] as String,
      floorNumber: json['floorNumber'] as String,
      residentType: json['residentType'] as String,
      moveInDate: DateTime.parse(json['moveInDate'] as String),
      moveOutDate: json['moveOutDate'] != null 
          ? DateTime.parse(json['moveOutDate'] as String) 
          : null,
      isActive: json['isActive'] as bool,
      profileImage: json['profileImage'] as String?,
      familyMembers: List<String>.from(json['familyMembers'] as List),
      preferences: Map<String, dynamic>.from(json['preferences'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'unitNumber': unitNumber,
      'buildingNumber': buildingNumber,
      'floorNumber': floorNumber,
      'residentType': residentType,
      'moveInDate': moveInDate.toIso8601String(),
      'moveOutDate': moveOutDate?.toIso8601String(),
      'isActive': isActive,
      'profileImage': profileImage,
      'familyMembers': familyMembers,
      'preferences': preferences,
    };
  }

  String get fullAddress => '$buildingNumber棟$floorNumber樓$unitNumber號';
} 