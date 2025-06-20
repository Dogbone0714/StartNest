import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/invitation_code.dart';
import '../../services/community/serverpod_client_service.dart';

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
      final result = await ServerpodClientService.getAllInvitationCodes();
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
                  hintText: '請輸入房號（如：1101）',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    // 驗證房號格式（純數字）
                    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                      return '房號只能包含數字';
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
        final generateResult = await ServerpodClientService.generateInvitationCode(
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

  Future<void> _deleteInvitationCode(String code, bool isUsed) async {
    if (isUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已使用的邀請碼無法刪除'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('確認刪除'),
        content: Text('確定要刪除邀請碼「$code」嗎？\n此操作無法撤銷。'),
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
        final result = await ServerpodClientService.deleteInvitationCode(code);
        
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

  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('邀請碼管理'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _generateInvitationCode,
            tooltip: '生成邀請碼',
          ),
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
                            Icons.qr_code_outlined,
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
                          ElevatedButton.icon(
                            onPressed: _generateInvitationCode,
                            icon: const Icon(Icons.add),
                            label: const Text('生成邀請碼'),
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
                          final codeData = _invitationCodes[index];
                          final isUsed = codeData['isUsed'] ?? false;
                          final isExpired = codeData['isExpired'] ?? false;
                          final isValid = codeData['isValid'] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isValid 
                                    ? Colors.green[100] 
                                    : isUsed 
                                        ? Colors.blue[100] 
                                        : Colors.red[100],
                                child: Icon(
                                  isValid 
                                      ? Icons.check_circle 
                                      : isUsed 
                                          ? Icons.person 
                                          : Icons.error,
                                  color: isValid 
                                      ? Colors.green[700] 
                                      : isUsed 
                                          ? Colors.blue[700] 
                                          : Colors.red[700],
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    codeData['code'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isValid)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '有效',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    )
                                  else if (isUsed)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '已使用',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '已過期',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('創建時間：${_formatDateTime(codeData['createdAt'])}'),
                                  Text('過期時間：${_formatDateTime(codeData['expiresAt'])}'),
                                  if (codeData['unit'] != null && codeData['unit'].isNotEmpty)
                                    Text('預設房號：${codeData['unit']}'),
                                  if (isUsed && codeData['usedBy'] != null)
                                    Text('使用者：${codeData['usedBy']}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'copy') {
                                    Clipboard.setData(ClipboardData(text: codeData['code']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('邀請碼已複製到剪貼板')),
                                    );
                                  } else if (value == 'delete') {
                                    _deleteInvitationCode(codeData['code'], isUsed);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'copy',
                                    child: Row(
                                      children: [
                                        Icon(Icons.copy),
                                        SizedBox(width: 8),
                                        Text('複製'),
                                      ],
                                    ),
                                  ),
                                  if (!isUsed)
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