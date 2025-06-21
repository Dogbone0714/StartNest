import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/community/auth_service.dart';
import '../../services/community/firebase_service.dart';
import '../../utils/constants/app_constants.dart';
import 'resident_voting_detail_screen.dart';

class ResidentVotingScreen extends StatefulWidget {
  const ResidentVotingScreen({super.key});

  @override
  State<ResidentVotingScreen> createState() => _ResidentVotingScreenState();
}

class _ResidentVotingScreenState extends State<ResidentVotingScreen> {
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

  String _getUserVote(Map<String, dynamic> topic) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUserId;
    final votes = topic['votes'] as Map<String, dynamic>? ?? {};
    return votes[currentUserId]?.toString() ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('表決投票'),
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
                          final userVote = _getUserVote(topic);
                          final hasVoted = userVote.isNotEmpty;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: Icon(
                                hasVoted ? Icons.check_circle : Icons.how_to_vote,
                                color: hasVoted ? Colors.green : _getStatusColor(topic['status']),
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
                                      if (hasVoted) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getVoteColor(userVote),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getVoteText(userVote),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDateTime(topic['start_date'])} - ${_formatDateTime(topic['end_date'])}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
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
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ResidentVotingDetailScreen(
                                    votingTopic: topic,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
} 