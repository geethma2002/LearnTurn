import 'package:flutter/material.dart';
import '../models/mentor.dart';

class MentorsScreen extends StatelessWidget {
  final List<Mentor> mentors;
  const MentorsScreen({super.key, required this.mentors});

  void _showMentorDetails(BuildContext context, Mentor mentor) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mentor.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text('Skills: ${mentor.skills.join(', ')}'),
              Text('Experience: ${mentor.experienceYears} yrs'),
              Text('Availability: ${mentor.availability.join(', ')}'),
              Text('Email: ${mentor.contactEmail}'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.82,
      ),
      itemCount: mentors.length,
      itemBuilder: (context, i) {
        final m = mentors[i];
        final String shortSkills = m.skills.take(3).join(' • ');
        final String shortAvail = m.availability.isEmpty
            ? 'Flexible'
            : m.availability.take(2).join(' • ');
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showMentorDetails(context, m),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shortSkills.isEmpty ? 'Skills: -' : shortSkills,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, height: 1.1, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m.experienceYears} yrs exp',
                      style: const TextStyle(fontSize: 10, height: 1.1, color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shortAvail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, height: 1.1, color: Colors.black45),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.contactEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, height: 1.1, color: Colors.black38),
                    ),
                    const Spacer(),
                    Text(
                      'Tap for full details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 8, height: 1.1, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
