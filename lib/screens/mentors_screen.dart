import 'package:flutter/material.dart';
import '../models/mentor.dart';

class MentorsScreen extends StatelessWidget {
  final List<Mentor> mentors;
  const MentorsScreen({super.key, required this.mentors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mentors.length,
      itemBuilder: (context, i) {
        final m = mentors[i];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(m.name),
            subtitle: Text(
              'Skills: ${m.skills.join(', ')}\nExp: ${m.experienceYears} yrs\nAvail: ${m.availability.join(', ')}\nEmail: ${m.contactEmail}',
            ),
          ),
        );
      },
    );
  }
}
