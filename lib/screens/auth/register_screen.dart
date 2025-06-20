import 'package:flutter/material.dart';
import '../../services/community/serverpod_client_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _invitationCodeController = TextEditingController();
  final _unitController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedRole;
  String _building = '子敬園'; // 固定大樓名稱

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _invitationCodeController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 驗證邀請碼
      final invitationResult = await ServerpodClientService.validateInvitationCode(
        _invitationCodeController.text.trim(),
      );

      if (invitationResult == null || !invitationResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(invitationResult?['message'] ?? '邀請碼驗證失敗'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 使用邀請碼
      final useResult = await ServerpodClientService.useInvitationCode(
        _invitationCodeController.text.trim(),
        _usernameController.text.trim(),
      );

      if (useResult == null || !useResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(useResult?['message'] ?? '使用邀請碼失敗'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 註冊用戶
      final result = await ServerpodClientService.register(
        _usernameController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _selectedRole ?? '住戶',
        _building,
        _unitController.text.trim(),
      );

      if (result != null && result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('註冊成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? '註冊失敗'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('註冊失敗: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('註冊'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // 邀請碼
              TextFormField(
                controller: _invitationCodeController,
                decoration: const InputDecoration(
                  labelText: '邀請碼 *',
                  hintText: '請輸入管理員提供的邀請碼',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入邀請碼';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 用戶名
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用戶名 *',
                  hintText: '請輸入用戶名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入用戶名';
                  }
                  if (value.length < 3) {
                    return '用戶名至少需要3個字符';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 密碼
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密碼 *',
                  hintText: '請輸入密碼',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請輸入密碼';
                  }
                  if (value.length < 6) {
                    return '密碼至少需要6個字符';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 確認密碼
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '確認密碼 *',
                  hintText: '請再次輸入密碼',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請確認密碼';
                  }
                  if (value != _passwordController.text) {
                    return '兩次輸入的密碼不一致';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 姓名
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名 *',
                  hintText: '請輸入真實姓名',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入姓名';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 房號
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: '房號 *',
                  hintText: '請輸入房號（如：1101）',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入房號';
                  }
                  // 驗證房號格式（純數字）
                  if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                    return '房號只能包含數字';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // 註冊按鈕
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '註冊',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 16),
              
              // 返回登入
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('已有帳號？返回登入'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 