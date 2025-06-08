import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/startup_space.dart';
import '../services/startup_service.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  static const LatLng _miaoliCenter = LatLng(24.5647, 120.8233); // 苗栗市中心坐标
  final StartupService _startupService = StartupService();
  List<StartupSpace> _startupSpaces = [];
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _loadStartupSpaces();
  }

  void _loadStartupSpaces() {
    setState(() {
      _startupSpaces = _startupService.getAllStartupSpaces();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == '全部') {
        _startupSpaces = _startupService.getAllStartupSpaces();
      } else {
        _startupSpaces = _startupService.getStartupSpacesByCategory(category);
      }
    });
  }

  Future<void> _showSearchScreen() async {
    final result = await Navigator.push<StartupSpace>(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );

    if (result != null) {
      _showStartupDetails(result);
      _mapController.move(result.coordinates, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('苗栗創業地圖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchScreen,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterSheet(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _miaoliCenter,
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.startnest.miaoli',
                ),
                MarkerLayer(
                  markers: _startupSpaces.map((space) {
                    return Marker(
                      point: space.coordinates,
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          _showStartupDetails(space);
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _startupSpaces.length,
              itemBuilder: (context, index) {
                final space = _startupSpaces[index];
                return _buildStartupCard(space);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '選擇類別',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              '全部',
              '科技',
              '文創',
              '農業',
            ].map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  if (selected) {
                    _filterByCategory(category);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartupCard(StartupSpace space) {
    return Card(
      margin: const EdgeInsets.only(right: 16),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getCategoryIcon(space.category),
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              space.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text('地點：${space.location}'),
            Text('類別：${space.category}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${space.rating}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '科技':
        return Icons.business;
      case '文創':
        return Icons.store;
      case '農業':
        return Icons.agriculture;
      default:
        return Icons.business;
    }
  }

  void _showStartupDetails(StartupSpace space) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              space.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('地點：${space.location}'),
            Text('類別：${space.category}'),
            const SizedBox(height: 16),
            Text(
              space.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '設施：',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Wrap(
              spacing: 8,
              children: space.facilities.map((facility) {
                return Chip(label: Text(facility));
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('聯絡方式：${space.contactInfo}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: 實現導航功能
              },
              child: const Text('導航到這裡'),
            ),
          ],
        ),
      ),
    );
  }
} 