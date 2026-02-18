import '../../../core/constants/app_constants.dart';

class Booking {
  final String id;
  final String studentId;
  final String tutorId;
  final String subject;
  final DateTime scheduledAt;
  final int durationMinutes;
  final double agreedPrice;
  final BookingStatus status;
  final String? videoMeetingLink;
  final String? paymentIntentId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.subject,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.agreedPrice,
    this.status = BookingStatus.pending,
    this.videoMeetingLink,
    this.paymentIntentId,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'studentId': studentId,
        'tutorId': tutorId,
        'subject': subject,
        'scheduledAt': scheduledAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'agreedPrice': agreedPrice,
        'status': status.name,
        'videoMeetingLink': videoMeetingLink,
        'paymentIntentId': paymentIntentId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static Booking fromMap(String id, Map<String, dynamic> map) => Booking(
        id: id,
        studentId: map['studentId'] as String,
        tutorId: map['tutorId'] as String,
        subject: map['subject'] as String,
        scheduledAt: DateTime.parse(map['scheduledAt'] as String),
        durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
        agreedPrice: (map['agreedPrice'] as num?)?.toDouble() ?? 0,
        status: BookingStatus.values.byName(map['status'] as String? ?? 'pending'),
        videoMeetingLink: map['videoMeetingLink'] as String?,
        paymentIntentId: map['paymentIntentId'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null,
      );
}
