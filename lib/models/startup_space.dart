import 'package:latlong2/latlong.dart';

class StartupSpace {
  final String id;
  final String name;
  final String description;
  final String location;
  final String category;
  final LatLng coordinates;
  final String imageUrl;
  final String contactInfo;
  final List<String> facilities;
  final double rating;

  StartupSpace({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.category,
    required this.coordinates,
    required this.imageUrl,
    required this.contactInfo,
    required this.facilities,
    required this.rating,
  });

  factory StartupSpace.fromJson(Map<String, dynamic> json) {
    return StartupSpace(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      category: json['category'] as String,
      coordinates: LatLng(
        json['coordinates']['latitude'] as double,
        json['coordinates']['longitude'] as double,
      ),
      imageUrl: json['imageUrl'] as String,
      contactInfo: json['contactInfo'] as String,
      facilities: List<String>.from(json['facilities'] as List),
      rating: json['rating'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'category': category,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
      'imageUrl': imageUrl,
      'contactInfo': contactInfo,
      'facilities': facilities,
      'rating': rating,
    };
  }
} 