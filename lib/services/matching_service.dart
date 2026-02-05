import '../models/mentor.dart';
import '../models/student.dart';

class MatchingService {
  static List<Mentor> matchMentors({
    required Student student,
    required List<Mentor> mentors,
  }) {
    // Simple scoring: +2 per desiredSkill match, +1 per interest match
    final List<(Mentor, int)> scored = mentors.map((m) {
      int score = 0;
      for (final skill in student.desiredSkills) {
        if (m.skills.map((s) => s.toLowerCase()).contains(skill.toLowerCase())) {
          score += 2;
        }
      }
      for (final interest in student.interests) {
        if (m.skills.map((s) => s.toLowerCase()).contains(interest.toLowerCase())) {
          score += 1;
        }
      }
      return (m, score);
    }).toList();

    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.where((e) => e.$2 > 0).map((e) => e.$1).toList();
  }
}
