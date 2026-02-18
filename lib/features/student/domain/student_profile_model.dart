class StudentProfile {
  final String userId;
  final String? displayName;
  final String? photoUrl;
  final String? gradeLevel;
  final List<String> subjectsNeeded;
  final String? preferredSchedule;
  final String? budget;
  final String? learningGoals;
  final DateTime? updatedAt;

  const StudentProfile({
    required this.userId,
    this.displayName,
    this.photoUrl,
    this.gradeLevel,
    this.subjectsNeeded = const [],
    this.preferredSchedule,
    this.budget,
    this.learningGoals,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'gradeLevel': gradeLevel,
        'subjectsNeeded': subjectsNeeded,
        'preferredSchedule': preferredSchedule,
        'budget': budget,
        'learningGoals': learningGoals,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  static StudentProfile fromMap(Map<String, dynamic> map) => StudentProfile(
        userId: map['userId'] as String,
        displayName: map['displayName'] as String?,
        photoUrl: map['photoUrl'] as String?,
        gradeLevel: map['gradeLevel'] as String?,
        subjectsNeeded: List<String>.from(map['subjectsNeeded'] as List? ?? []),
        preferredSchedule: map['preferredSchedule'] as String?,
        budget: map['budget'] as String?,
        learningGoals: map['learningGoals'] as String?,
        updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'] as String) : null,
      );
}
