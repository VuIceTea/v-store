import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class UserProfile {
  final String userId;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? photoURL;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? address;
  final String? city;
  final String? country;
  final String loginProvider;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final Map<String, dynamic>? preferences;

  UserProfile({
    required this.userId,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.photoURL,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.country,
    required this.loginProvider,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
    this.isPhoneVerified = false,
    this.preferences,
  });

  factory UserProfile.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? country,
    String loginProvider = 'email',
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: firebaseUser.uid,
      displayName: firebaseUser.displayName ?? 'Người dùng',
      email: firebaseUser.email ?? '',
      phoneNumber: phoneNumber ?? firebaseUser.phoneNumber,
      photoURL: firebaseUser.photoURL,
      dateOfBirth: dateOfBirth,
      gender: gender,
      address: address,
      city: city,
      country: country,
      loginProvider: loginProvider,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
      isPhoneVerified: firebaseUser.phoneNumber != null,
      preferences: preferences,
    );
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserProfile(
      userId: doc.id,
      displayName: _safeStringFromData(data['displayName']) ?? 'Người dùng',
      email: _safeStringFromData(data['email']) ?? '',
      phoneNumber: _safeStringFromData(data['phoneNumber']),
      photoURL: _safeStringFromData(data['photoURL']),
      dateOfBirth: data['dateOfBirth'] != null
          ? _safeDateFromTimestamp(data['dateOfBirth'])
          : null,
      gender: _safeStringFromData(data['gender']),
      address: _safeStringFromData(data['address']),
      city: _safeStringFromData(data['city']),
      country: _safeStringFromData(data['country']),
      loginProvider: _safeStringFromData(data['loginProvider']) ?? 'email',
      createdAt: _safeDateFromTimestamp(data['createdAt']) ?? DateTime.now(),
      updatedAt: _safeDateFromTimestamp(data['updatedAt']) ?? DateTime.now(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      preferences: data['preferences'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'address': address,
      'city': city,
      'country': country,
      'loginProvider': loginProvider,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'preferences': preferences,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoURL,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? city,
    String? country,
    String? loginProvider,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      loginProvider: loginProvider ?? this.loginProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  String get displayNameOrEmail => displayName.isNotEmpty ? displayName : email;

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  bool get isProfileComplete {
    return displayName.isNotEmpty &&
        email.isNotEmpty &&
        phoneNumber?.isNotEmpty == true &&
        dateOfBirth != null &&
        gender?.isNotEmpty == true;
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, displayName: $displayName, email: $email, loginProvider: $loginProvider)';
  }

  static String? _safeStringFromData(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is List) {
      if (data.isEmpty) return null;
      return data.first?.toString();
    }
    return data.toString();
  }

  static DateTime? _safeDateFromTimestamp(dynamic data) {
    if (data == null) return null;
    if (data is Timestamp) return data.toDate();
    if (data is String) {
      try {
        return DateTime.parse(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class User {
  String userId;
  String username;
  String? email;
  String password;

  User({
    required this.userId,
    required this.username,
    this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
