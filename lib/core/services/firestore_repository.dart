import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../../features/tutor/domain/tutor_profile_model.dart';
import '../../features/student/domain/student_profile_model.dart';
import '../../features/bookings/domain/booking_model.dart';
import '../../features/reviews/domain/review_model.dart';
import '../../features/chat/domain/message_model.dart';

class FirestoreRepository {
  final _db = FirebaseFirestore.instance;

  // ---------- Tutors ----------
  Future<TutorProfile?> getTutorProfile(String userId) async {
    final doc = await _db.collection(AppCollections.tutors).doc(userId).get();
    if (!doc.exists) return null;
    return TutorProfile.fromMap({...doc.data()!, 'userId': doc.id});
  }

  Future<void> setTutorProfile(TutorProfile profile) async {
    await _db.collection(AppCollections.tutors).doc(profile.userId).set(
          {...profile.toMap(), 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
  }

  Stream<TutorProfile?> tutorProfileStream(String userId) {
    return _db.collection(AppCollections.tutors).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TutorProfile.fromMap({...doc.data()!, 'userId': doc.id});
    });
  }

  Future<List<TutorProfile>> searchTutors({
    String? subject,
    double? maxPrice,
    double? minRating,
    int limit = kPageSize,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection(AppCollections.tutors);
    if (subject != null && subject.isNotEmpty) {
      q = q.where('subjects', arrayContains: subject);
    }
    q = q.limit(limit * 3);
    final snap = await q.get();
    var list = snap.docs.map((d) => TutorProfile.fromMap({...d.data(), 'userId': d.id})).toList();
    if (maxPrice != null && maxPrice > 0) list = list.where((t) => t.hourlyRate <= maxPrice!).toList();
    if (minRating != null && minRating > 0) list = list.where((t) => (t.averageRating ?? 0) >= minRating).toList();
    return list.take(limit).toList();
  }

  // ---------- Students ----------
  Future<StudentProfile?> getStudentProfile(String userId) async {
    final doc = await _db.collection(AppCollections.students).doc(userId).get();
    if (!doc.exists) return null;
    return StudentProfile.fromMap({...doc.data()!, 'userId': doc.id});
  }

  Future<void> setStudentProfile(StudentProfile profile) async {
    await _db.collection(AppCollections.students).doc(profile.userId).set(
          {...profile.toMap(), 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
  }

  Stream<StudentProfile?> studentProfileStream(String userId) {
    return _db.collection(AppCollections.students).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return StudentProfile.fromMap({...doc.data()!, 'userId': doc.id});
    });
  }

  // ---------- Bookings ----------
  Future<String> createBooking(Booking booking) async {
    final ref = _db.collection(AppCollections.bookings).doc();
    await ref.set(booking.toMap()..['id'] = ref.id);
    return ref.id;
  }

  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    await _db.collection(AppCollections.bookings).doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setBookingVideoLink(String id, String link) async {
    await _db.collection(AppCollections.bookings).doc(id).update({
      'videoMeetingLink': link,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Booking>> studentBookingsStream(String studentId) {
    return _db
        .collection(AppCollections.bookings)
        .where('studentId', isEqualTo: studentId)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Booking>> tutorBookingsStream(String tutorId) {
    return _db
        .collection(AppCollections.bookings)
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());
  }

  Future<Booking?> getBooking(String id) async {
    final doc = await _db.collection(AppCollections.bookings).doc(id).get();
    if (!doc.exists) return null;
    return Booking.fromMap(doc.id, doc.data()!);
  }

  // ---------- Reviews ----------
  Future<void> addReview(Review review) async {
    await _db.collection(AppCollections.reviews).doc(review.id).set(review.toMap());
    // Update tutor average rating (simplified: could use Cloud Function)
    final tutorReviews = await _db.collection(AppCollections.reviews).where('tutorId', isEqualTo: review.tutorId).get();
    final ratings = tutorReviews.docs.map((d) => (d.data()['rating'] as num).toInt()).toList();
    final avg = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
    await _db.collection(AppCollections.tutors).doc(review.tutorId).update({
      'averageRating': avg,
      'totalReviews': ratings.length,
    });
  }

  Future<List<Review>> getReviewsForTutor(String tutorId, {int limit = 20}) async {
    final snap = await _db
        .collection(AppCollections.reviews)
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => Review.fromMap(d.id, d.data())).toList();
  }

  // ---------- Chats & Messages ----------
  Future<String> getOrCreateChat(String userId1, String userId2) async {
    final ids = [userId1, userId2]..sort();
    final chatId = '${ids[0]}_${ids[1]}';
    final ref = _db.collection(AppCollections.chats).doc(chatId);
    if (!(await ref.get()).exists) {
      await ref.set({
        'participantIds': ids,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  Stream<List<ChatMessage>> messagesStream(String chatId) {
    return _db
        .collection(AppCollections.chats)
        .doc(chatId)
        .collection(AppCollections.messages)
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final ref = _db.collection(AppCollections.chats).doc(chatId).collection(AppCollections.messages).doc();
    final data = {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'read': false,
    };
    await ref.set(data);
    await _db.collection(AppCollections.chats).doc(chatId).update({
      'lastMessageText': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastSenderId': senderId,
    });
  }

  Stream<List<ChatRoom>> userChatsStream(String userId) {
    return _db
        .collection(AppCollections.chats)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatRoom.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  // ---------- Favorites ----------
  Future<void> addFavorite(String studentId, String tutorId) async {
    await _db.collection(AppCollections.favorites).doc('${studentId}_$tutorId').set({
      'studentId': studentId,
      'tutorId': tutorId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String studentId, String tutorId) async {
    await _db.collection(AppCollections.favorites).doc('${studentId}_$tutorId').delete();
  }

  Future<bool> isFavorite(String studentId, String tutorId) async {
    final doc = await _db.collection(AppCollections.favorites).doc('${studentId}_$tutorId').get();
    return doc.exists;
  }

  Future<List<String>> getFavoriteTutorIds(String studentId) async {
    final snap = await _db.collection(AppCollections.favorites).where('studentId', isEqualTo: studentId).get();
    return snap.docs.map((d) => d.data()['tutorId'] as String).toList();
  }
}
