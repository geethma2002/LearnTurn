class Review {
  final String id;
  final String bookingId;
  final String tutorId;
  final String studentId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'bookingId': bookingId,
        'tutorId': tutorId,
        'studentId': studentId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.toIso8601String(),
      };

  static Review fromMap(String id, Map<String, dynamic> map) => Review(
        id: id,
        bookingId: map['bookingId'] as String,
        tutorId: map['tutorId'] as String,
        studentId: map['studentId'] as String,
        rating: (map['rating'] as num).toInt(),
        comment: map['comment'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
