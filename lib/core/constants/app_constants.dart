/// Firestore collection names
class AppCollections {
  static const String users = 'users';
  static const String tutors = 'tutors';
  static const String students = 'students';
  static const String bookings = 'bookings';
  static const String reviews = 'reviews';
  static const String messages = 'messages';
  static const String chats = 'chats';
  static const String favorites = 'favorites';
}

/// Booking status
enum BookingStatus { pending, accepted, completed, cancelled }

/// Default pagination
const int kPageSize = 15;
