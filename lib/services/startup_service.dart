import 'package:latlong2/latlong.dart';
import '../models/startup_space.dart';

class StartupService {
  // 模擬數據
  static final List<StartupSpace> _startupSpaces = [
    StartupSpace(
      id: '1',
      name: '苗栗科技創業中心',
      description: '提供科技創業團隊辦公空間和資源支持',
      location: '苗栗市',
      category: '科技',
      coordinates: LatLng(24.5647, 120.8233),
      imageUrl: 'assets/images/space1.jpg',
      contactInfo: '037-123456',
      facilities: ['會議室', '高速網路', '咖啡廳'],
      rating: 4.5,
    ),
    StartupSpace(
      id: '2',
      name: '竹南文創園區',
      description: '文創產業孵化基地',
      location: '竹南鎮',
      category: '文創',
      coordinates: LatLng(24.6861, 120.8783),
      imageUrl: 'assets/images/space2.jpg',
      contactInfo: '037-234567',
      facilities: ['展示廳', '工作坊', '休息區'],
      rating: 4.2,
    ),
    StartupSpace(
      id: '3',
      name: '頭份農業創新中心',
      description: '農業科技創業基地',
      location: '頭份市',
      category: '農業',
      coordinates: LatLng(24.6878, 120.9044),
      imageUrl: 'assets/images/space3.jpg',
      contactInfo: '037-345678',
      facilities: ['實驗室', '溫室', '培訓室'],
      rating: 4.0,
    ),
  ];

  // 獲取所有創業空間
  List<StartupSpace> getAllStartupSpaces() {
    return _startupSpaces;
  }

  // 根據類別篩選
  List<StartupSpace> getStartupSpacesByCategory(String category) {
    return _startupSpaces.where((space) => space.category == category).toList();
  }

  // 根據位置篩選
  List<StartupSpace> getStartupSpacesByLocation(String location) {
    return _startupSpaces.where((space) => space.location == location).toList();
  }

  // 搜尋創業空間
  List<StartupSpace> searchStartupSpaces(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _startupSpaces.where((space) {
      return space.name.toLowerCase().contains(lowercaseQuery) ||
          space.description.toLowerCase().contains(lowercaseQuery) ||
          space.location.toLowerCase().contains(lowercaseQuery) ||
          space.category.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // 獲取特定創業空間
  StartupSpace? getStartupSpaceById(String id) {
    try {
      return _startupSpaces.firstWhere((space) => space.id == id);
    } catch (e) {
      return null;
    }
  }
} 