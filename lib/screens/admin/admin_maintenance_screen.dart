import 'package:flutter/material.dart';
import '../../services/community/serverpod_client_service.dart';
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
  String _selectedStatus = '全部';

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
      final result = await ServerpodClientService.getAllMaintenanceRequests();
      if (result['success'] == true) {
        setState(() {
          _maintenanceRequests = List<Map<String, dynamic>>.from(result['maintenanceRequests'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? '載入維修單失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入維修單時發生錯誤：$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    final result = await ServerpodClientService.updateMaintenanceRequestStatus(id, newStatus);
    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '狀態更新成功')),
        );
        _loadMaintenanceRequests();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '更新失敗')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredRequests {
    if (_selectedStatus == '全部') {
      return _maintenanceRequests;
    }
    return _maintenanceRequests.where((request) => request['status'] == _selectedStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待處理':
        return Colors.orange;
      case '處理中':
        return Colors.blue;
      case '已完成':
        return Colors.green;
      case '已取消':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '高':
        return Colors.red;
      case '中':
        return Colors.orange;
      case '低':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('維修單管理'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMaintenanceRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          // 狀態篩選
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Row(
              children: [
                const Text('狀態篩選：'),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: ['全部', '待處理', '處理中', '已完成', '已取消']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // 維修單列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!),
                            const SizedBox(height: AppConstants.paddingMedium),
                            ElevatedButton(
                              onPressed: _loadMaintenanceRequests,
                              child: const Text('重試'),
                            ),
                          ],
                        ),
                      )
                    : _filteredRequests.isEmpty
                        ? const Center(
                            child: Text('目前沒有維修單'),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMaintenanceRequests,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              itemCount: _filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = _filteredRequests[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                                  child: ExpansionTile(
                                    leading: Icon(
                                      Icons.build,
                                      color: _getStatusColor(request['status'] ?? ''),
                                    ),
                                    title: Text(
                                      request['title'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('申請人：${request['createdBy'] ?? ''}'),
                                        Text('單元：${request['unit'] ?? ''}'),
                                        Text(
                                          '申請時間：${_formatDateTime(request['createdAt'])}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '問題描述：',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(request['description'] ?? ''),
                                            const SizedBox(height: AppConstants.paddingMedium),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getPriorityColor(request['priority'] ?? '').withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    '優先級：${request['priority'] ?? ''}',
                                                    style: TextStyle(
                                                      color: _getPriorityColor(request['priority'] ?? ''),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: AppConstants.paddingMedium),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(request['status'] ?? '').withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    '狀態：${request['status'] ?? ''}',
                                                    style: TextStyle(
                                                      color: _getStatusColor(request['status'] ?? ''),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: AppConstants.paddingMedium),
                                            if (request['status'] != '已完成' && request['status'] != '已取消')
                                              Row(
                                                children: [
                                                  const Text('更新狀態：'),
                                                  const SizedBox(width: AppConstants.paddingSmall),
                                                  Expanded(
                                                    child: DropdownButton<String>(
                                                      value: request['status'],
                                                      isExpanded: true,
                                                      items: ['待處理', '處理中', '已完成', '已取消']
                                                          .map((status) => DropdownMenuItem(
                                                                value: status,
                                                                child: Text(status),
                                                              ))
                                                          .toList(),
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          _updateStatus(request['id'], value);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
} 