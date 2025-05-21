class PushupAnalysis {
  final String id;
  final String userId;
  final String createdAt;
  final int repetitionCount;
  final double score;
  final Summary summary;

  PushupAnalysis({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.repetitionCount,
    required this.score,
    required this.summary,
  });

  factory PushupAnalysis.fromJson(Map<String, dynamic> json) {
    return PushupAnalysis(
      id: json['id'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      repetitionCount: json['repetition_count'],
      score: (json['score'] as num).toDouble(),
      summary: Summary.fromJson(json['summary']),
    );
  }
}

class Summary {
  final double elbowMotion;
  final double shoulderAbduction;
  final double elbowFlexion;
  final double lowerBodyAlignmentScore;

  Summary({
    required this.elbowMotion,
    required this.shoulderAbduction,
    required this.elbowFlexion,
    required this.lowerBodyAlignmentScore,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      elbowMotion: (json['elbow_motion'] as num).toDouble(),
      shoulderAbduction: (json['shoulder_abduction'] as num).toDouble(),
      elbowFlexion: (json['elbow_flexion'] as num).toDouble(),
      lowerBodyAlignmentScore: (json['lower_body_alignment_score'] as num).toDouble(),
    );
  }
}
