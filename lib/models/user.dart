class User {
  final int? id;
  final String email;
  final String password;
  final String username;
  final String role;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.username,
    this.role = 'ADMIN',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'ADMIN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'username': username,
      'role': role,
    };
  }
}

