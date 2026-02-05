import '../models/mentor.dart';
import '../models/student.dart';

class MockData {
  static List<String> timeSlots = const [
    'Mon 10:00', 'Mon 14:00', 'Tue 10:00', 'Tue 14:00', 'Wed 10:00'
  ];

  static List<Mentor> mentors = const [
    Mentor(
      id: 1,
      name: 'Alice Johnson',
      skills: ['Flutter', 'Dart', 'UI/UX'],
      experienceYears: 5,
      availability: ['Mon 10:00', 'Tue 14:00'],
      contactEmail: 'alice@example.com',
    ),
    Mentor(
      id: 2,
      name: 'Brian Smith',
      skills: ['Data Science', 'Python', 'ML'],
      experienceYears: 7,
      availability: ['Mon 14:00', 'Wed 10:00'],
      contactEmail: 'brian@example.com',
    ),
    Mentor(
      id: 3,
      name: 'Prof. Chen',
      skills: ['Algorithms', 'Java', 'Systems'],
      experienceYears: 12,
      availability: ['Tue 10:00', 'Tue 14:00'],
      contactEmail: 'chen@example.edu',
    ),
  ];

  static List<Student> students = const [
    Student(
      id: 1,
      name: 'Geeth',
      interests: ['Mobile Apps', 'UI'],
      goals: ['Build portfolio', 'Internship'],
      desiredSkills: ['Flutter', 'Dart'],
    ),
    Student(
      id: 2,
      name: 'Sara',
      interests: ['AI', 'Data'],
      goals: ['Research', 'Graduate school'],
      desiredSkills: ['Python', 'ML'],
    ),
    Student(
      id: 3,
      name: 'Arun',
      interests: ['Backend', 'Systems'],
      goals: ['Improve coding', 'Job-ready'],
      desiredSkills: ['Java', 'Algorithms'],
    ),
  ];
}
