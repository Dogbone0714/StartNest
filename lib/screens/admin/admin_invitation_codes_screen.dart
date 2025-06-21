import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/invitation_code.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';

class AdminInvitationCodesScreen extends StatefulWidget {
  const AdminInvitationCodesScreen({super.key});

  @override
  State<AdminInvitationCodesScreen> createState() => _AdminInvitationCodesScreenState();
}

class _AdminInvitationCodesScreenState extends State<AdminInvitationCodesScreen> {
  List<Map<String, dynamic>> _invitationCodes = [];
  bool _isLoading = true;
  String? _errorMessage;
  TextEditingController _unitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvitationCodes();
  }

  Future<void> _loadInvitationCodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FirebaseService.getAllInvitationCodes();
      if (result['success'] == true) {
        setState(() {
          _invitationCodes = List<Map<String, dynamic>>.from(result['codes']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? '載入邀請碼列表失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入邀請碼列表時發生錯誤';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateInvitationCode() async {
    final formKey = GlobalKey<FormState>();
    int validDays = 7;
    String unit = '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生成邀請碼'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '有效天數',
                  hintText: '預設7天',
                ),
                keyboardType: TextInputType.number,
                initialValue: '7',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入有效天數';
                  }
                  final days = int.tryParse(value);
                  if (days == null || days <= 0) {
                    return '請輸入有效的天數';
                  }
                  return null;
                },
                onSaved: (value) => validDays = int.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: '房號',
                  hintText: '請輸入房號（如：56-1號1樓、119-2號2樓）',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    // 驗證房號格式（56-*號*樓 或 119-*號*樓）
                    if (!RegExp(r'^(56|119)-\d+號\d+樓$').hasMatch(value.trim())) {
                      return '房號格式：56-*號*樓 或 119-*號*樓';
                    }
                  }
                  return null;
                },
              ),
            ],
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
                  'validDays': validDays,
                  'unit': unit,
                });
              }
            },
            child: const Text('生成'),
          ),
        ],
      ),
    );

    if (result != null) {
      _showLoadingDialog('生成邀請碼中...');
      
      try {
        final generateResult = await FirebaseService.generateInvitationCode(
          'admin',
          validDays: result['validDays'],
          unit: result['unit'].isNotEmpty ? result['unit'] : null,
        );

        Navigator.of(context).pop(); // 關閉載入對話框

        if (generateResult['success'] == true) {
          // 顯示生成的邀請碼
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('邀請碼生成成功'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('邀請碼：${generateResult['code']}'),
                  const SizedBox(height: 8),
                  Text('有效期至：${DateTime.parse(generateResult['expiresAt']).toString().substring(0, 16)}'),
                  if (result['unit'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('預設房號：${result['unit']}'),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    '請將此邀請碼提供給住戶，住戶註冊時需要輸入此邀請碼。',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('關閉'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: generateResult['code']));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('邀請碼已複製到剪貼板')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('複製'),
                ),
              ],
            ),
          );
          
          _loadInvitationCodes(); // 重新載入邀請碼列表
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(generateResult['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // 關閉載入對話框
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('生成邀請碼時發生錯誤'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteInvitationCode(String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除邀請碼「$code」嗎？'),
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
      _showLoadingDialog('刪除邀請碼中...');
      
      try {
        final result = await FirebaseService.deleteInvitationCode(code);
        
        Navigator.of(context).pop(); // 關閉載入對話框
        
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          _loadInvitationCodes(); // 重新載入邀請碼列表
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
            content: Text('刪除邀請碼時發生錯誤'),
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

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '未知時間';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _getStatusText(Map<String, dynamic> code) {
    if (code['is_used'] == true) {
      return '已使用';
    }
    
    final expiresAtString = code['expires_at']?.toString();
    if (expiresAtString == null || expiresAtString.isEmpty) {
      return '無效';
    }
    
    try {
      final expiresAt = DateTime.parse(expiresAtString);
      if (expiresAt.isBefore(DateTime.now())) {
        return '已過期';
      }
      return '有效';
    } catch (e) {
      return '無效';
    }
  }

  Color _getStatusColor(Map<String, dynamic> code) {
    if (code['is_used'] == true) {
      return Colors.grey;
    }
    
    final expiresAtString = code['expires_at']?.toString();
    if (expiresAtString == null || expiresAtString.isEmpty) {
      return Colors.red;
    }
    
    try {
      final expiresAt = DateTime.parse(expiresAtString);
      if (expiresAt.isBefore(DateTime.now())) {
        return Colors.red;
      }
      return Colors.green;
    } catch (e) {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('邀請碼管理'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvitationCodes,
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
                        onPressed: _loadInvitationCodes,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _invitationCodes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.vpn_key_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暫無邀請碼',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '點擊下方按鈕生成新的邀請碼',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadInvitationCodes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _invitationCodes.length,
                        itemBuilder: (context, index) {
                          final code = _invitationCodes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      code['code'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(code),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getStatusText(code),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '創建時間：${_formatDateTime(code['created_at'])}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '過期時間：${_formatDateTime(code['expires_at'])}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (code['unit'] != null && code['unit'].isNotEmpty)
                                    Flexible(
                                      child: Text(
                                        '預設房號：${code['unit']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  if (code['is_used'] == true) ...[
                                    Flexible(
                                      child: Text(
                                        '使用時間：${_formatDateTime(code['used_at'])}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '使用用戶：${code['used_by']}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'copy') {
                                    Clipboard.setData(ClipboardData(text: code['code']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('邀請碼已複製到剪貼板')),
                                    );
                                  } else if (value == 'delete') {
                                    _deleteInvitationCode(code['code']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'copy',
                                    child: Row(
                                      children: [
                                        Icon(Icons.copy, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('複製邀請碼', style: TextStyle(color: Colors.blue)),
                                      ],
                                    ),
                                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _generateInvitationCode,
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }
} 