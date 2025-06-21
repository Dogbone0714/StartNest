import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';
import 'admin_create_voting_topic_screen.dart';

class AdminVotingScreen extends StatefulWidget {
  const AdminVotingScreen({super.key});

  @override
  State<AdminVotingScreen> createState() => _AdminVotingScreenState();
}

class _AdminVotingScreenState extends State<AdminVotingScreen> {
  List<Map<String, dynamic>> _votingTopics = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVotingTopics();
  }

  Future<void> _loadVotingTopics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await FirebaseService.getAllVotingTopics();
      
      if (result != null && result['success'] == true) {
        setState(() {
          _votingTopics = List<Map<String, dynamic>>.from(result['topics']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result?['message'] ?? '獲取表決議題失敗';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '獲取表決議題失敗：$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createVotingTopic() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminCreateVotingTopicScreen(),
      ),
    );

    if (result == true) {
      _loadVotingTopics();
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

  void _showVotingResults(Map<String, dynamic> topic) {
    final totalVotes = topic['total_votes'] ?? 0;
    final approveVotes = topic['approve_votes'] ?? 0;
    final rejectVotes = topic['reject_votes'] ?? 0;
    final abstainVotes = topic['abstain_votes'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${topic['title']} - 投票結果'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              // 圓餅圖
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (approveVotes > 0)
                        PieChartSectionData(
                          color: Colors.green,
                          value: approveVotes.toDouble(),
                          title: '贊成\n$approveVotes票',
                          radius: 60,
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
                          radius: 60,
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
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 統計數據
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Text('總投票數：$totalVotes票', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
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
        title: const Text('表決管理'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVotingTopics,
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
                        onPressed: _loadVotingTopics,
                        child: const Text('重試'),
                      ),
                    ],
                  ),
                )
              : _votingTopics.isEmpty
                  ? const Center(child: Text('暫無表決議題'))
                  : RefreshIndicator(
                      onRefresh: _loadVotingTopics,
                      child: ListView.builder(
                        itemCount: _votingTopics.length,
                        itemBuilder: (context, index) {
                          final topic = _votingTopics[index];
                          final totalVotes = topic['total_votes'] ?? 0;
                          final approveVotes = topic['approve_votes'] ?? 0;
                          final rejectVotes = topic['reject_votes'] ?? 0;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Icon(
                                Icons.how_to_vote,
                                color: _getStatusColor(topic['status']),
                              ),
                              title: Text(
                                topic['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic['description'],
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
                                          color: _getStatusColor(topic['status']),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusText(topic['status']),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${_formatDateTime(topic['start_date'])} - ${_formatDateTime(topic['end_date'])}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '總投票：$totalVotes票',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '贊成：$approveVotes票',
                                        style: const TextStyle(fontSize: 12, color: Colors.green),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '反對：$rejectVotes票',
                                        style: const TextStyle(fontSize: 12, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => _showVotingResults(topic),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createVotingTopic,
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
} 