class AuthResponse {
  final String token;
  final User user;
  final String? refreshToken;
  final DateTime? expiresAt;

  AuthResponse({
    required this.token,
    required this.user,
    this.refreshToken,
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'refreshToken': refreshToken,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AuthResponse(token: ${token.substring(0, 10)}..., user: $user)';
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  @override
  String toString() {
    return 'User(id: $id, email: $email, firstName: $firstName, lastName: $lastName)';
  }
}