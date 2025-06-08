import 'package:flutter/material.dart';
import '../models/startup_space.dart';
import '../services/startup_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StartupService _startupService = StartupService();
  List<StartupSpace> _searchResults = [];
  bool _isSearching = false;

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _startupService.searchStartupSpaces(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '搜尋創業空間...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _performSearch('');
            },
          ),
        ],
      ),
      body: _isSearching
          ? _searchResults.isEmpty
              ? const Center(
                  child: Text('沒有找到相關結果'),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final space = _searchResults[index];
                    return ListTile(
                      leading: Icon(_getCategoryIcon(space.category)),
                      title: Text(space.name),
                      subtitle: Text('${space.location} · ${space.category}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${space.rating}'),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context, space);
                      },
                    );
                  },
                )
          : const Center(
              child: Text('輸入關鍵字開始搜尋'),
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
} 