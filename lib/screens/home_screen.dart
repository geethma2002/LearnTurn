import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../models/student.dart';
import '../models/session.dart';
import '../models/feedback.dart';
import '../services/mock_data.dart';
import '../services/firestore_service.dart';
import 'mentors_screen.dart';
import 'students_screen.dart';
import 'match_screen.dart';
import 'booking_screen.dart';
import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  late List<Mentor> mentors;
  late List<Student> students;
  final List<Session> sessions = [];
  final List<SessionFeedback> feedbacks = [];
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final loadedMentors = await _firestore.getMentors();
      final loadedStudents = await _firestore.getStudents();
      final loadedSessions = await _firestore.getSessions();
      final loadedFeedbacks = await _firestore.getFeedbacks();

      setState(() {
        if (loadedMentors.isEmpty) {
          // Seed Firestore with mock data
          mentors = List.of(MockData.mentors);
          for (final m in mentors) {
            _firestore.addMentor(m);
          }
        } else {
          mentors = loadedMentors;
        }

        if (loadedStudents.isEmpty) {
          students = List.of(MockData.students);
          for (final s in students) {
            _firestore.addStudent(s);
          }
        } else {
          students = loadedStudents;
        }

        sessions.addAll(loadedSessions);
        feedbacks.addAll(loadedFeedbacks);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        mentors = List.of(MockData.mentors);
        students = List.of(MockData.students);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('LearnTurn')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = [
      MentorsScreen(mentors: mentors),
      StudentsScreen(students: students),
      MatchScreen(students: students, mentors: mentors),
      BookingScreen(
        students: students,
        mentors: mentors,
        sessions: sessions,
        onCreateSession: (s) async {
          final newId = await _firestore.getNextSessionId();
          final sessionToCreate = Session(
            id: newId,
            mentorId: s.mentorId,
            studentId: s.studentId,
            timeSlot: s.timeSlot,
            status: s.status,
          );
          await _firestore.createSession(sessionToCreate);
          setState(() => sessions.add(sessionToCreate));
        },
        onUpdateStatus: (id, status) async {
          await _firestore.updateSessionStatus(id, status);
          setState(() {
            final idx = sessions.indexWhere((e) => e.id == id);
            if (idx != -1) sessions[idx].status = status;
          });
        },
      ),
      FeedbackScreen(
        sessions: sessions,
        mentors: mentors,
        students: students,
        feedbacks: feedbacks,
        onSubmitFeedback: (f) async {
          await _firestore.submitFeedback(f);
          setState(() => feedbacks.add(f));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('LearnTurn')),
      body: tabs[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mentors'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Match'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
        ],
      ),
    );
  }
}
