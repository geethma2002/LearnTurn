import '../../../core/constants/app_constants.dart';

class TutorProfile {
  final String userId;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final List<String> subjects;
  final String? qualifications;
  final int experienceYears;
  final double hourlyRate;
  final List<AvailabilitySlot> availability;
  final bool verified;
  final double? averageRating;
  final int? totalReviews;
  final DateTime? updatedAt;

  const TutorProfile({
    required this.userId,
    this.displayName,
    this.photoUrl,
    this.bio,
    this.subjects = const [],
    this.qualifications,
    this.experienceYears = 0,
    this.hourlyRate = 0,
    this.availability = const [],
    this.verified = false,
    this.averageRating,
    this.totalReviews,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'bio': bio,
        'subjects': subjects,
        'qualifications': qualifications,
        'experienceYears': experienceYears,
        'hourlyRate': hourlyRate,
        'availability': availability.map((e) => e.toMap()).toList(),
        'verified': verified,
        'averageRating': averageRating,
        'totalReviews': totalReviews,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static TutorProfile fromMap(Map<String, dynamic> map) => TutorProfile(
        userId: map['userId'] as String,
        displayName: map['displayName'] as String?,
        photoUrl: map['photoUrl'] as String?,
        bio: map['bio'] as String?,
        subjects: List<String>.from(map['subjects'] as List? ?? []),
        qualifications: map['qualifications'] as String?,
        experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
        hourlyRate: (map['hourlyRate'] as num?)?.toDouble() ?? 0,
        availability: (map['availability'] as List?)
                ?.map((e) => AvailabilitySlot.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        verified: map['verified'] as bool? ?? false,
        averageRating: (map['averageRating'] as num?)?.toDouble(),
        totalReviews: (map['totalReviews'] as num?)?.toInt(),
        updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null,
      );
}

class AvailabilitySlot {
  final String day; // e.g. Monday, Tuesday
  final String startTime; // e.g. 09:00
  final String endTime;   // e.g. 17:00

  const AvailabilitySlot({required this.day, required this.startTime, required this.endTime});

  Map<String, dynamic> toMap() => {'day': day, 'startTime': startTime, 'endTime': endTime};

  static AvailabilitySlot fromMap(Map<String, dynamic> map) => AvailabilitySlot(
        day: map['day'] as String,
        startTime: map['startTime'] as String,
        endTime: map['endTime'] as String,
      );
}
