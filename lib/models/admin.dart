import 'package:v_store/models/user.dart';

class Admin extends User {
  String name;
  Admin({
    required super.userId,
    required super.username,
    required super.password,
    super.email,
    required this.name,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      password: json['password'] as String,
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'password': password,
      'name': name,
    };
  }
}
