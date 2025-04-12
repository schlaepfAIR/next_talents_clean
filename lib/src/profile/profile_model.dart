class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String userType;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userType,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      userType: data['userType'] ?? 'bewerber',
    );
  }
}
