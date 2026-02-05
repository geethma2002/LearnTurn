import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../models/student.dart';
import '../services/matching_service.dart';

class MatchScreen extends StatefulWidget {
  final List<Student> students;
  final List<Mentor> mentors;
  const MatchScreen({super.key, required this.students, required this.mentors});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  Student? selected;

  @override
  Widget build(BuildContext context) {
    final List<Mentor> matches = selected == null
        ? []
        : MatchingService.matchMentors(student: selected!, mentors: widget.mentors);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Student to find mentors', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButton<Student>(
            isExpanded: true,
            value: selected,
            hint: const Text('Choose a student'),
            items: widget.students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
            onChanged: (s) => setState(() => selected = s),
          ),
          const SizedBox(height: 12),
          if (selected == null)
            const Text('No student selected.')
          else if (matches.isEmpty)
            const Text('No mentors match this student yet.')
          else
            Expanded(
              child: ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, i) {
                  final m = matches[i];
                  return Card(
                    child: ListTile(
                      title: Text(m.name),
                      subtitle: Text('Skills: ${m.skills.join(', ')}\nAvail: ${m.availability.join(', ')}'),
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}
