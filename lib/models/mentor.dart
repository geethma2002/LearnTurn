class Mentor {
  final int id;
  final String name;
  final List<String> skills;
  final int experienceYears;
  final List<String> availability; // e.g., "Mon 10:00", "Tue 14:00"
  final String contactEmail;

  const Mentor({
    required this.id,
    required this.name,
    required this.skills,
    required this.experienceYears,
    required this.availability,
    required this.contactEmail,
  });
}
