import 'package:flutter/material.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';
import 'add_maintenance_request_screen.dart';
import 'maintenance_detail_screen.dart';

class ResidentMaintenanceScreen extends StatefulWidget {
  const ResidentMaintenanceScreen({super.key});

  @override
  State<ResidentMaintenanceScreen> createState() => _ResidentMaintenanceScreenState();
}

class _ResidentMaintenanceScreenState extends State<ResidentMaintenanceScreen> {
  List<Map<String, dynamic>> _maintenanceRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceRequests();
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '未知時間';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}年${dateTime.month.toString().padLeft(2, '0')}月${dateTime.day.toString().padLeft(2, '0')}日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '時間格式錯誤';
    }
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

  Future<void> _addMaintenanceRequest() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMaintenanceRequestScreen(),
      ),
    );

    if (result == true) {
      _loadMaintenanceRequests();
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

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('描述：${request['description']}'),
              if (request['location']?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text('位置：${request['location']}'),
              ],
              const SizedBox(height: 8),
              Text('狀態：${_getStatusText(request['status'])}'),
              const SizedBox(height: 8),
              Text('提交時間：${_formatDateTime(request['created_at'])}'),
              if (request['attachments']?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                const Text('附件：'),
                const SizedBox(height: 4),
                Text('共 ${request['attachments'].length} 張圖片'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('維修請求'),
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
                          final hasAttachments = request['attachments']?.isNotEmpty == true;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Icon(
                                hasAttachments ? Icons.attach_file : Icons.build,
                                color: hasAttachments ? Colors.blue : Colors.grey,
                              ),
                              title: Text(
                                request['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request['description'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(request['status']),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusText(request['status']),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      if (hasAttachments) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.attach_file,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${request['attachments'].length}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDateTime(request['created_at']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MaintenanceDetailScreen(
                                    maintenanceRequest: request,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMaintenanceRequest,
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
} 