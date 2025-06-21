class VotingTopic {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime createdAt;
  final String status; // 'active', 'closed', 'draft'
  final Map<String, String> votes; // userId -> vote ('approve', 'reject', 'abstain')
  final int totalVotes;
  final int approveVotes;
  final int rejectVotes;
  final int abstainVotes;

  VotingTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.createdAt,
    required this.status,
    required this.votes,
    required this.totalVotes,
    required this.approveVotes,
    required this.rejectVotes,
    required this.abstainVotes,
  });

  factory VotingTopic.fromMap(Map<String, dynamic> map, String id) {
    final votes = <String, String>{};
    if (map['votes'] != null) {
      final votesMap = map['votes'] as Map<dynamic, dynamic>;
      votesMap.forEach((key, value) {
        votes[key.toString()] = value.toString();
      });
    }

    return VotingTopic(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      startDate: DateTime.parse(map['start_date']?.toString() ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['end_date']?.toString() ?? DateTime.now().toIso8601String()),
      createdBy: map['created_by']?.toString() ?? '',
      createdAt: DateTime.parse(map['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      status: map['status']?.toString() ?? 'draft',
      votes: votes,
      totalVotes: map['total_votes'] ?? 0,
      approveVotes: map['approve_votes'] ?? 0,
      rejectVotes: map['reject_votes'] ?? 0,
      abstainVotes: map['abstain_votes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'votes': votes,
      'total_votes': totalVotes,
      'approve_votes': approveVotes,
      'reject_votes': rejectVotes,
      'abstain_votes': abstainVotes,
    };
  }

  VotingTopic copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    DateTime? createdAt,
    String? status,
    Map<String, String>? votes,
    int? totalVotes,
    int? approveVotes,
    int? rejectVotes,
    int? abstainVotes,
  }) {
    return VotingTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      votes: votes ?? this.votes,
      totalVotes: totalVotes ?? this.totalVotes,
      approveVotes: approveVotes ?? this.approveVotes,
      rejectVotes: rejectVotes ?? this.rejectVotes,
      abstainVotes: abstainVotes ?? this.abstainVotes,
    );
  }
} 