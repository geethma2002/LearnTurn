enum SessionStatus { pending, approved, rejected }

class Session {
  final int id;
  final int mentorId;
  final int studentId;
  final String timeSlot;
  SessionStatus status;

  Session({
    required this.id,
    required this.mentorId,
    required this.studentId,
    required this.timeSlot,
    this.status = SessionStatus.pending,
  });
}
