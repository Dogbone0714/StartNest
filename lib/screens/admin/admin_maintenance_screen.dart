import 'package:flutter/material.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';

class AdminMaintenanceScreen extends StatefulWidget {
  const AdminMaintenanceScreen({super.key});

  @override
  State<AdminMaintenanceScreen> createState() => _AdminMaintenanceScreenState();
}

class _AdminMaintenanceScreenState extends State<AdminMaintenanceScreen> {
  List<Map<String, dynamic>> _maintenanceRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceRequests();
  }

  Future<void> _loadMaintenanceRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FirebaseService.getAllMaintenanceRequests();
      
      if (result != null && result['success'] == true) {
        setState(() {
          _maintenanceRequests = List<Map<String, dynamic>>.from(result['requests']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result?['message'] ?? '獲取維修請求列表失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '獲取維修請求列表失敗：$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRequestStatus(String id, String status) async {
    try {
      final success = await FirebaseService.updateMaintenanceRequestStatus(id, status);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('狀態更新成功')),
        );
        _loadMaintenanceRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('狀態更新失敗')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('狀態更新失敗：$e')),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待處理';
      case 'in_progress':
        return '處理中';
      case 'completed':
        return '已完成';
      default:
        return '未知';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('維修管理'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMaintenanceRequests,
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
                        onPressed: _loadMaintenanceRequests,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _maintenanceRequests.isEmpty
                  ? const Center(child: Text('暫無維修請求'))
                  : RefreshIndicator(
                      onRefresh: _loadMaintenanceRequests,
                      child: ListView.builder(
                        itemCount: _maintenanceRequests.length,
                        itemBuilder: (context, index) {
                          final request = _maintenanceRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(
                                request['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${request['description']}\n狀態：${_getStatusText(request['status'])} | 提交時間：${request['created_at']}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  _updateRequestStatus(request['id'], value);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'pending',
                                    child: Text('設為待處理'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'in_progress',
                                    child: Text('設為處理中'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'completed',
                                    child: Text('設為已完成'),
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
