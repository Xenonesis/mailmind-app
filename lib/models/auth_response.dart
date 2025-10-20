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
      token: json['access_token'] ?? json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
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
  final String name;
  final String? firstName;
  final String? lastName;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.firstName,
    this.lastName,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? json['first_name'],
      lastName: json['lastName'] ?? json['last_name'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  String get fullName => name.isNotEmpty ? name : '${firstName ?? ''} ${lastName ?? ''}'.trim();

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}