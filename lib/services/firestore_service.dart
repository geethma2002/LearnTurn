import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mentor.dart';
import '../models/student.dart';
import '../models/session.dart';
import '../models/feedback.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static const String mentorsCollection = 'mentors';
  static const String studentsCollection = 'students';
  static const String sessionsCollection = 'sessions';
  static const String feedbacksCollection = 'feedbacks';

  // ========== Mentors ==========
  Future<List<Mentor>> getMentors() async {
    final QuerySnapshot snapshot = await _db.collection(mentorsCollection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Mentor(
        id: data['id'] as int,
        name: data['name'] as String,
        skills: List<String>.from(data['skills'] as List),
        experienceYears: data['experienceYears'] as int,
        availability: List<String>.from(data['availability'] as List),
        contactEmail: data['contactEmail'] as String,
      );
    }).toList();
  }

  Future<void> addMentor(Mentor mentor) async {
    await _db.collection(mentorsCollection).doc(mentor.id.toString()).set({
      'id': mentor.id,
      'name': mentor.name,
      'skills': mentor.skills,
      'experienceYears': mentor.experienceYears,
      'availability': mentor.availability,
      'contactEmail': mentor.contactEmail,
    });
  }

  // ========== Students ==========
  Future<List<Student>> getStudents() async {
    final QuerySnapshot snapshot = await _db.collection(studentsCollection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Student(
        id: data['id'] as int,
        name: data['name'] as String,
        interests: List<String>.from(data['interests'] as List),
        goals: List<String>.from(data['goals'] as List),
        desiredSkills: List<String>.from(data['desiredSkills'] as List),
      );
    }).toList();
  }

  Future<void> addStudent(Student student) async {
    await _db.collection(studentsCollection).doc(student.id.toString()).set({
      'id': student.id,
      'name': student.name,
      'interests': student.interests,
      'goals': student.goals,
      'desiredSkills': student.desiredSkills,
    });
  }

  // ========== Sessions ==========
  Future<List<Session>> getSessions() async {
    final QuerySnapshot snapshot = await _db.collection(sessionsCollection).orderBy('id').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Session(
        id: data['id'] as int,
        mentorId: data['mentorId'] as int,
        studentId: data['studentId'] as int,
        timeSlot: data['timeSlot'] as String,
        status: SessionStatus.values.firstWhere(
          (s) => s.name == (data['status'] as String),
          orElse: () => SessionStatus.pending,
        ),
      );
    }).toList();
  }

  Future<void> createSession(Session session) async {
    await _db.collection(sessionsCollection).doc(session.id.toString()).set({
      'id': session.id,
      'mentorId': session.mentorId,
      'studentId': session.studentId,
      'timeSlot': session.timeSlot,
      'status': session.status.name,
    });
  }

  Future<void> updateSessionStatus(int sessionId, SessionStatus status) async {
    await _db.collection(sessionsCollection).doc(sessionId.toString()).update({
      'status': status.name,
    });
  }

  // ========== Feedbacks ==========
  Future<List<SessionFeedback>> getFeedbacks() async {
    final QuerySnapshot snapshot = await _db.collection(feedbacksCollection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return SessionFeedback(
        id: data['id'] as int,
        sessionId: data['sessionId'] as int,
        rating: data['rating'] as int,
        comments: data['comments'] as String,
      );
    }).toList();
  }

  Future<void> submitFeedback(SessionFeedback feedback) async {
    await _db.collection(feedbacksCollection).doc(feedback.id.toString()).set({
      'id': feedback.id,
      'sessionId': feedback.sessionId,
      'rating': feedback.rating,
      'comments': feedback.comments,
    });
  }

  // ========== Utilities ==========
  Future<int> getNextSessionId() async {
    final QuerySnapshot snapshot = await _db.collection(sessionsCollection).orderBy('id', descending: true).limit(1).get();
    if (snapshot.docs.isEmpty) return 1;
    final lastId = (snapshot.docs.first.data() as Map<String, dynamic>)['id'] as int;
    return lastId + 1;
  }

  Future<int> getNextFeedbackId() async {
    final QuerySnapshot snapshot = await _db.collection(feedbacksCollection).orderBy('id', descending: true).limit(1).get();
    if (snapshot.docs.isEmpty) return 1;
    final lastId = (snapshot.docs.first.data() as Map<String, dynamic>)['id'] as int;
    return lastId + 1;
  }
}
