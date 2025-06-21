import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community/auth_service.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';
import 'admin_announcements_screen.dart';
import 'admin_maintenance_screen.dart';
import 'admin_residents_screen.dart';
import 'admin_profile_screen.dart';
import 'admin_invitation_codes_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 並行加載統計數據和最近活動
      final results = await Future.wait([
        FirebaseService.getDashboardStats(),
        FirebaseService.getRecentActivities(limit: 5),
      ]);

      final statsResult = results[0];
      final activitiesResult = results[1];

      if (statsResult['success'] == true && activitiesResult['success'] == true) {
        setState(() {
          _stats = statsResult['stats'];
          _recentActivities = List<Map<String, dynamic>>.from(activitiesResult['activities']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '載入數據失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '載入數據失敗：$e';
        _isLoading = false;
      });
    }
  }

  String _formatTimeAgo(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '未知時間';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return '剛剛';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分鐘前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小時前';
      } else {
        return '${difference.inDays}天前';
      }
    } catch (e) {
      return '未知時間';
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'invitation_code':
        return Icons.qr_code;
      case 'maintenance_request':
        return Icons.build;
      case 'announcement':
        return Icons.announcement;
      case 'user_registration':
        return Icons.person_add;
      case 'user_deletion':
        return Icons.person_remove;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'invitation_code':
        return Colors.purple;
      case 'maintenance_request':
        return Colors.orange;
      case 'announcement':
        return Colors.blue;
      case 'user_registration':
        return Colors.green;
      case 'user_deletion':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAnnouncementDetail(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
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
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('子敬園管理 - ${authService.userName.isNotEmpty ? authService.userName : '管理員'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: 顯示通知
            },
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
                        onPressed: _loadDashboardData,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 歡迎訊息
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingLarge),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings,
                                  size: 48,
                                  color: Color(AppConstants.primaryColor),
                                ),
                                const SizedBox(width: AppConstants.paddingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '歡迎回來，管理員！',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: AppConstants.paddingSmall),
                                      Text(
                                        '今天是 ${DateTime.now().year}年${DateTime.now().month}月${DateTime.now().day}日',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),

                        // 統計卡片
                        Text(
                          '系統概覽',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: AppConstants.paddingMedium,
                          mainAxisSpacing: AppConstants.paddingMedium,
                          children: [
                            _buildStatCard(
                              context,
                              '總用戶數',
                              '${_stats['total_users'] ?? 0}',
                              Icons.people,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              context,
                              '住戶數量',
                              '${_stats['total_residents'] ?? 0}',
                              Icons.home,
                              Colors.green,
                            ),
                            _buildStatCard(
                              context,
                              '有效邀請碼',
                              '${_stats['valid_invitation_codes'] ?? 0}',
                              Icons.qr_code,
                              Colors.purple,
                            ),
                            _buildStatCard(
                              context,
                              '待處理維修',
                              '${_stats['pending_maintenance_requests'] ?? 0}',
                              Icons.build,
                              Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),

                        // 快速功能
                        Text(
                          '快速功能',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: AppConstants.paddingMedium,
                          mainAxisSpacing: AppConstants.paddingMedium,
                          children: [
                            _buildQuickActionCard(
                              context,
                              '發布公告',
                              Icons.announcement,
                              Colors.blue,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AdminAnnouncementsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickActionCard(
                              context,
                              '處理維修',
                              Icons.build,
                              Colors.orange,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AdminMaintenanceScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickActionCard(
                              context,
                              '住戶管理',
                              Icons.people,
                              Colors.green,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AdminResidentsScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildQuickActionCard(
                              context,
                              '生成邀請碼',
                              Icons.qr_code,
                              Colors.purple,
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AdminInvitationCodesScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),

                        // 最近活動
                        Text(
                          '最近活動',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Card(
                          child: _recentActivities.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(AppConstants.paddingLarge),
                                  child: Center(
                                    child: Text('暫無活動記錄'),
                                  ),
                                )
                              : Column(
                                  children: _recentActivities.map((activity) {
                                    final activityType = activity['type']?.toString() ?? '';
                                    final activityTitle = activity['title']?.toString() ?? '';
                                    final activityDescription = activity['description']?.toString() ?? '';
                                    final metadata = activity['metadata'] ?? {};
                                    
                                    // 如果是公告類型，顯示完整內容
                                    String displayContent = activityDescription;
                                    if (activityType == 'announcement' && metadata['full_content'] != null) {
                                      final fullContent = metadata['full_content'].toString();
                                      // 限制內容長度，避免顯示過長
                                      displayContent = fullContent.length > 100 
                                          ? '${fullContent.substring(0, 100)}...' 
                                          : fullContent;
                                    }
                                    
                                    return ListTile(
                                      leading: Icon(
                                        _getActivityIcon(activityType),
                                        color: _getActivityColor(activityType),
                                      ),
                                      title: Text(
                                        activityTitle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        displayContent,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      trailing: Text(
                                        _formatTimeAgo(activity['created_at']?.toString()),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      onTap: activityType == 'announcement' && metadata['full_content'] != null
                                          ? () {
                                              _showAnnouncementDetail(
                                                metadata['title']?.toString() ?? '', 
                                                metadata['full_content']?.toString() ?? ''
                                              );
                                            }
                                          : null,
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 