import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community/auth_service.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';

class AddMaintenanceRequestScreen extends StatefulWidget {
  const AddMaintenanceRequestScreen({super.key});

  @override
  State<AddMaintenanceRequestScreen> createState() => _AddMaintenanceRequestScreenState();
}

class _AddMaintenanceRequestScreenState extends State<AddMaintenanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUserId = authService.currentUserId;
      if (currentUserId.isEmpty) {
        setState(() {
          _errorMessage = '用戶未登入';
        });
        return;
      }
      
      // 提交維修請求
      final result = await FirebaseService.addMaintenanceRequest(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // 返回並刷新列表
        }
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '提交維修請求失敗：$e';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增維修請求'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 標題
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '標題 *',
                  border: OutlineInputBorder(),
                  hintText: '請簡要描述問題',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入標題';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 位置
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '位置',
                  border: OutlineInputBorder(),
                  hintText: '例如：客廳、廚房、浴室等',
                ),
              ),
              const SizedBox(height: 16),

              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '詳細描述 *',
                  border: OutlineInputBorder(),
                  hintText: '請詳細描述問題情況',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入詳細描述';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 附件上傳
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_file),
                          const SizedBox(width: 8),
                          const Text(
                            '附件',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('附件功能已移除')),
                            ),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('添加圖片'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '可上傳問題現場的照片，幫助維修人員更好地了解情況',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 錯誤訊息
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // 提交按鈕
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('提交中...'),
                          ],
                        )
                      : const Text('提交維修請求'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 