import 'package:flutter/material.dart';
import '../models/session.dart';
import '../models/feedback.dart';
import '../models/mentor.dart';
import '../models/student.dart';

class FeedbackScreen extends StatefulWidget {
  final List<Session> sessions;
  final List<Mentor> mentors;
  final List<Student> students;
  final List<SessionFeedback> feedbacks;
  final void Function(SessionFeedback) onSubmitFeedback;

  const FeedbackScreen({
    super.key,
    required this.sessions,
    required this.mentors,
    required this.students,
    required this.feedbacks,
    required this.onSubmitFeedback,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  Session? selectedSession;
  int rating = 5;
  final TextEditingController commentsCtrl = TextEditingController();

  int _nextFeedbackId() => (widget.feedbacks.isEmpty ? 1 : (widget.feedbacks.map((f) => f.id).reduce((a,b)=>a>b?a:b) + 1));

  @override
  Widget build(BuildContext context) {
    final approvedSessions = widget.sessions.where((s) => s.status == SessionStatus.approved).toList();

    // Reports: avg rating per mentor
    final Map<int, List<int>> ratingsByMentor = {};
    for (final f in widget.feedbacks) {
      final session = widget.sessions.firstWhere((s) => s.id == f.sessionId, orElse: () => Session(id: -1, mentorId: -1, studentId: -1, timeSlot: '', status: SessionStatus.pending));
      if (session.id != -1) {
        ratingsByMentor.putIfAbsent(session.mentorId, () => []);
        ratingsByMentor[session.mentorId]!.add(f.rating);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Leave Feedback for Approved Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Session>(
                        value: selectedSession,
                        decoration: const InputDecoration(labelText: 'Approved session'),
                        items: approvedSessions.map((s) {
                          final studentName = widget.students.firstWhere((e) => e.id == s.studentId).name;
                          final mentorName = widget.mentors.firstWhere((e) => e.id == s.mentorId).name;
                          return DropdownMenuItem(
                            value: s,
                            child: Text('Session #${s.id} • $studentName → $mentorName • ${s.timeSlot}'),
                          );
                        }).toList(),
                        onChanged: (s) => setState(() => selectedSession = s),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: rating,
                        decoration: const InputDecoration(labelText: 'Rating'),
                        items: [1,2,3,4,5].map((r) => DropdownMenuItem(value: r, child: Text('$r'))).toList(),
                        onChanged: (r) => setState(() => rating = r ?? 5),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: commentsCtrl,
                        decoration: const InputDecoration(labelText: 'Comments'),
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: selectedSession == null ? null : () {
                            final f = SessionFeedback(
                              id: _nextFeedbackId(),
                              sessionId: selectedSession!.id,
                              rating: rating,
                              comments: commentsCtrl.text,
                            );
                            widget.onSubmitFeedback(f);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted.')));
                            setState(() { selectedSession = null; rating = 5; commentsCtrl.clear(); });
                          },
                          child: const Text('Submit Feedback'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reports: Mentor Ratings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 300,
                        child: ratingsByMentor.isEmpty
                            ? const Center(child: Text('No feedback yet'))
                            : ListView(
                                children: ratingsByMentor.entries.map((e) {
                                  final mentor = widget.mentors.firstWhere((m) => m.id == e.key);
                                  final avg = e.value.isEmpty ? 0 : e.value.reduce((a,b)=>a+b) / e.value.length;
                                  return ListTile(
                                    title: Text(mentor.name),
                                    subtitle: Text('Average rating: ${avg.toStringAsFixed(2)} (${e.value.length} feedbacks)'),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
