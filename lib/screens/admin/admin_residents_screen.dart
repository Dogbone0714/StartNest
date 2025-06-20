import 'package:flutter/material.dart';
import '../../models/resident.dart';
import '../../services/community/serverpod_client_service.dart';

class AdminResidentsScreen extends StatefulWidget {
  const AdminResidentsScreen({super.key});

  @override
  State<AdminResidentsScreen> createState() => _AdminResidentsScreenState();
}

class _AdminResidentsScreenState extends State<AdminResidentsScreen> {
  List<Resident> _residents = [];
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
      final result = await ServerpodClientService.getAllUsers();
      if (result != null && result['success'] == true) {
        final users = result['users'] as List;
        setState(() {
          _residents = users
              .map((user) => Resident.fromMap(user))
              .where((resident) => resident.role == '住戶')
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result?['message'] ?? '載入住戶列表失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入住戶列表時發生錯誤';
        _isLoading = false;
      });
    }
  }

  Future<void> _addResident() async {
    final formKey = GlobalKey<FormState>();
    String username = '';
    String password = '';
    String name = '';
    String unit = '';

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增住戶'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '帳號',
                    hintText: '請輸入帳號',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入帳號';
                    }
                    if (value == 'admin') {
                      return 'admin 為保留帳號';
                    }
                    return null;
                  },
                  onSaved: (value) => username = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '密碼',
                    hintText: '請輸入密碼',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入密碼';
                    }
                    if (value.length < 6) {
                      return '密碼至少需要6位字符';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    hintText: '請輸入姓名',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入姓名';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '房號',
                    hintText: '例如：A棟1001',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '請輸入房號';
                    }
                    return null;
                  },
                  onSaved: (value) => unit = value ?? '',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.of(context).pop({
                  'username': username,
                  'password': password,
                  'name': name,
                  'unit': unit,
                });
              }
            },
            child: const Text('新增'),
          ),
        ],
      ),
    );

    if (result != null) {
      _showLoadingDialog('新增住戶中...');
      
      try {
        final addResult = await ServerpodClientService.addResident(
          result['username']!,
          result['password']!,
          result['name']!,
          result['unit']!,
        );

        Navigator.of(context).pop(); // 關閉載入對話框

        if (addResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(addResult['message']),
              backgroundColor: Colors.green,
            ),
          );
          _loadResidents(); // 重新載入住戶列表
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(addResult['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // 關閉載入對話框
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('新增住戶時發生錯誤'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteResident(Resident resident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除住戶「${resident.name}」嗎？\n此操作無法撤銷。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _showLoadingDialog('刪除住戶中...');
      
      try {
        final result = await ServerpodClientService.deleteResident(resident.username);
        
        Navigator.of(context).pop(); // 關閉載入對話框

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          _loadResidents(); // 重新載入住戶列表
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // 關閉載入對話框
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('刪除住戶時發生錯誤'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('住戶管理'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addResident,
            tooltip: '新增住戶',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResidents,
            tooltip: '重新載入',
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
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadResidents,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _residents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暫無住戶資料',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addResident,
                            icon: const Icon(Icons.add),
                            label: const Text('新增住戶'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadResidents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _residents.length,
                        itemBuilder: (context, index) {
                          final resident = _residents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Text(
                                  resident.name.isNotEmpty ? resident.name[0] : '?',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                resident.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('帳號：${resident.username}'),
                                  Text('房號：${resident.unit}'),
                                  Text('大樓：${resident.building}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    _deleteResident(resident);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('刪除', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
} 