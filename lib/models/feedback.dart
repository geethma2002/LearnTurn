class SessionFeedback {
  final int id;
  final int sessionId;
  final int rating; // 1..5
  final String comments;

  const SessionFeedback({
    required this.id,
    required this.sessionId,
    required this.rating,
    required this.comments,
  });
}
