import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../models/student.dart';
import '../models/session.dart';
import '../services/mock_data.dart';

class BookingScreen extends StatefulWidget {
  final List<Student> students;
  final List<Mentor> mentors;
  final List<Session> sessions;
  final void Function(Session) onCreateSession;
  final void Function(int sessionId, SessionStatus status) onUpdateStatus;

  const BookingScreen({
    super.key,
    required this.students,
    required this.mentors,
    required this.sessions,
    required this.onCreateSession,
    required this.onUpdateStatus,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  Student? student;
  Mentor? mentor;
  String? timeSlot;

  int _nextSessionId() => (widget.sessions.isEmpty ? 1 : (widget.sessions.map((s) => s.id).reduce((a,b)=>a>b?a:b) + 1));

  @override
  Widget build(BuildContext context) {
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
                      const Text('Create a new mentoring session', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Student>(
                        value: student,
                        decoration: const InputDecoration(labelText: 'Student'),
                        items: widget.students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                        onChanged: (s) => setState(() => student = s),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Mentor>(
                        value: mentor,
                        decoration: const InputDecoration(labelText: 'Mentor'),
                        items: widget.mentors.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
                        onChanged: (m) => setState(() => mentor = m),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: timeSlot,
                        decoration: const InputDecoration(labelText: 'Time slot'),
                        items: MockData.timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (t) => setState(() => timeSlot = t),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: (student!=null && mentor!=null && timeSlot!=null)
                              ? () {
                                  final s = Session(
                                    id: _nextSessionId(),
                                    mentorId: mentor!.id,
                                    studentId: student!.id,
                                    timeSlot: timeSlot!,
                                    status: SessionStatus.pending,
                                  );
                                  widget.onCreateSession(s);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session created (pending).')));
                                  setState((){ student=null; mentor=null; timeSlot=null; });
                                }
                              : null,
                          child: const Text('Request Session'),
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
                      const Text('All Sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 360,
                        child: widget.sessions.isEmpty
                            ? const Center(child: Text('No sessions yet'))
                            : ListView.builder(
                                itemCount: widget.sessions.length,
                                itemBuilder: (context, i) {
                                  final s = widget.sessions[i];
                                  final st = s.status;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      title: Text('Session #${s.id} • ${s.timeSlot}'),
                                      subtitle: Text('Student: ${widget.students.firstWhere((e)=>e.id==s.studentId).name}\nMentor: ${widget.mentors.firstWhere((e)=>e.id==s.mentorId).name}\nStatus: ${st.name}'),
                                      trailing: Wrap(spacing: 8, children: [
                                        IconButton(
                                          tooltip: 'Approve',
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          onPressed: () => widget.onUpdateStatus(s.id, SessionStatus.approved),
                                        ),
                                        IconButton(
                                          tooltip: 'Reject',
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () => widget.onUpdateStatus(s.id, SessionStatus.rejected),
                                        ),
                                      ]),
                                    ),
                                  );
                                },
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
