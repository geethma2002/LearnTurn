enum UserRole { student, tutor }

extension UserRoleX on UserRole {
  bool get isStudent => this == UserRole.student;
  bool get isTutor => this == UserRole.tutor;
  String get label => this == UserRole.student ? 'Student' : 'Tutor';
}

class AppUser {
  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'role': role.name,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };

  static AppUser fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] as String,
        email: map['email'] as String,
        role: UserRole.values.byName(map['role'] as String),
        displayName: map['displayName'] as String?,
        photoUrl: map['photoUrl'] as String?,
      );
}
