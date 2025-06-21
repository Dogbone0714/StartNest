import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/community/auth_service.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';

class ResidentVotingDetailScreen extends StatefulWidget {
  final Map<String, dynamic> votingTopic;

  const ResidentVotingDetailScreen({
    super.key,
    required this.votingTopic,
  });

  @override
  State<ResidentVotingDetailScreen> createState() => _ResidentVotingDetailScreenState();
}

class _ResidentVotingDetailScreenState extends State<ResidentVotingDetailScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String? _userVote;
  Map<String, dynamic>? _topicDetails;

  @override
  void initState() {
    super.initState();
    _loadTopicDetails();
  }

  Future<void> _loadTopicDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FirebaseService.getVotingTopicDetails(widget.votingTopic['id']);
      
      if (result != null && result['success'] == true) {
        setState(() {
          _topicDetails = result['topic'];
          final votes = _topicDetails!['votes'] as Map<String, dynamic>? ?? {};
          final authService = Provider.of<AuthService>(context, listen: false);
          final currentUserId = authService.currentUserId;
          _userVote = votes[currentUserId]?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result?['message'] ?? '獲取議題詳情失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '獲取議題詳情失敗：$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitVote(String vote) async {
    setState(() {
      _isLoading = true;
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

      final result = await FirebaseService.voteOnTopic(
        topicId: widget.votingTopic['id'],
        userId: currentUserId,
        vote: vote,
      );

      if (result['success'] == true) {
        setState(() {
          _userVote = vote;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // 重新載入詳情
        _loadTopicDetails();
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '投票失敗：$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '未知時間';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.year}年${dateTime.month.toString().padLeft(2, '0')}月${dateTime.day.toString().padLeft(2, '0')}日';
    } catch (e) {
      return '時間格式錯誤';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return '進行中';
      case 'closed':
        return '已結束';
      case 'draft':
        return '草稿';
      default:
        return '未知';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'draft':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getVoteText(String vote) {
    switch (vote) {
      case 'approve':
        return '贊成';
      case 'reject':
        return '反對';
      case 'abstain':
        return '棄權';
      default:
        return '';
    }
  }

  Color _getVoteColor(String vote) {
    switch (vote) {
      case 'approve':
        return Colors.green;
      case 'reject':
        return Colors.red;
      case 'abstain':
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  bool _canVote() {
    if (_topicDetails == null) return false;
    final status = _topicDetails!['status']?.toString() ?? '';
    final endDate = DateTime.tryParse(_topicDetails!['end_date'] ?? '') ?? DateTime.now();
    return status == 'active' && DateTime.now().isBefore(endDate) && _userVote?.isEmpty == true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('議題詳情'),
          backgroundColor: const Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('議題詳情'),
          backgroundColor: const Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTopicDetails,
                child: const Text('重試'),
              ),
            ],
          ),
        ),
      );
    }

    if (_topicDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('議題詳情'),
          backgroundColor: const Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('議題不存在')),
      );
    }

    final topic = _topicDetails!;
    final totalVotes = topic['total_votes'] ?? 0;
    final approveVotes = topic['approve_votes'] ?? 0;
    final rejectVotes = topic['reject_votes'] ?? 0;
    final abstainVotes = topic['abstain_votes'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('議題詳情'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題和狀態
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            topic['title'] ?? '無標題',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(topic['status']),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusText(topic['status']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatDateTime(topic['start_date'])} - ${_formatDateTime(topic['end_date'])}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 描述
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '議題描述',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      topic['description'] ?? '無描述',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 投票選項（如果可以投票）
            if (_canVote()) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '請選擇您的投票',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _submitVote('approve'),
                              icon: const Icon(Icons.thumb_up),
                              label: const Text('贊成'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _submitVote('reject'),
                              icon: const Icon(Icons.thumb_down),
                              label: const Text('反對'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _submitVote('abstain'),
                              icon: const Icon(Icons.remove_circle_outline),
                              label: const Text('棄權'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 個人投票狀態
            if (_userVote?.isNotEmpty == true) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '您的投票',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getVoteColor(_userVote!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getVoteText(_userVote!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 投票結果
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '投票結果',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 圓餅圖
                    if (totalVotes > 0) ...[
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              if (approveVotes > 0)
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: approveVotes.toDouble(),
                                  title: '贊成\n$approveVotes票',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              if (rejectVotes > 0)
                                PieChartSectionData(
                                  color: Colors.red,
                                  value: rejectVotes.toDouble(),
                                  title: '反對\n$rejectVotes票',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              if (abstainVotes > 0)
                                PieChartSectionData(
                                  color: Colors.grey,
                                  value: abstainVotes.toDouble(),
                                  title: '棄權\n$abstainVotes票',
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 統計數據
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('總投票', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('$totalVotes票'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('贊成', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            Text('$approveVotes票'),
                            if (totalVotes > 0)
                              Text('${(approveVotes / totalVotes * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('反對', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            Text('$rejectVotes票'),
                            if (totalVotes > 0)
                              Text('${(rejectVotes / totalVotes * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('棄權', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            Text('$abstainVotes票'),
                            if (totalVotes > 0)
                              Text('${(abstainVotes / totalVotes * 100).toStringAsFixed(1)}%'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 