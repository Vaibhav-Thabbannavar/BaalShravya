class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String role; // 'admin', 'anm', 'parent'
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.createdAt,
  });

  // converts raw JSON from API into a UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }

  // converts UserModel back to JSON for storing in SecureStorage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'created_at': createdAt,
    };
  }
}

class AuthResponse {
  final UserModel user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}