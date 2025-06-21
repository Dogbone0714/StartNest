import 'package:flutter/material.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';

class AdminResidentsScreen extends StatefulWidget {
  const AdminResidentsScreen({super.key});

  @override
  State<AdminResidentsScreen> createState() => _AdminResidentsScreenState();
}

class _AdminResidentsScreenState extends State<AdminResidentsScreen> {
  List<Map<String, dynamic>> _residents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FirebaseService.getAllResidents();
      
      if (result != null && result['success'] == true) {
        setState(() {
          _residents = List<Map<String, dynamic>>.from(result['residents']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result?['message'] ?? '獲取住戶列表失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '獲取住戶列表失敗：$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addResident() async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final unitController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增住戶'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: '用戶名'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: '密碼'),
              obscureText: true,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: '房號'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final addResult = await FirebaseService.addResident(
                usernameController.text,
                passwordController.text,
                nameController.text,
                unitController.text,
              );
              Navigator.of(context).pop(addResult);
            },
            child: const Text('新增'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadResidents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  Future<void> _editResident(Map<String, dynamic> resident) async {
    final nameController = TextEditingController(text: resident['name']);
    final unitController = TextEditingController(text: resident['unit']);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('編輯住戶'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '姓名'),
            ),
            TextField(
              controller: unitController,
              decoration: const InputDecoration(labelText: '房號'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final updateResult = await FirebaseService.updateResidentInfo(
                resident['username'],
                nameController.text,
                unitController.text,
              );
              Navigator.of(context).pop(updateResult);
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadResidents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  Future<void> _deleteResident(Map<String, dynamic> resident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除住戶 ${resident['name']} 嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await FirebaseService.deleteResident(resident['username']);
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        _loadResidents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('住戶管理'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResidents,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadResidents,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _residents.isEmpty
                  ? const Center(child: Text('暫無住戶資料'))
                  : ListView.builder(
                      itemCount: _residents.length,
                      itemBuilder: (context, index) {
                        final resident = _residents[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              resident['name'],
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '房號：${resident['unit']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editResident(resident),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteResident(resident),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addResident,
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
} 