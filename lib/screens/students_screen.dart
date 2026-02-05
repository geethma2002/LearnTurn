import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentsScreen extends StatelessWidget {
  final List<Student> students;
  const StudentsScreen({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, i) {
        final s = students[i];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(s.name),
            subtitle: Text(
              'Interests: ${s.interests.join(', ')}\nGoals: ${s.goals.join(', ')}\nDesired: ${s.desiredSkills.join(', ')}',
            ),
          ),
        );
      },
    );
  }
}
