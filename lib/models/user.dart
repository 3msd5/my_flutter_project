import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String username;
  final String username_lower;
  final String name;
  final String name_lower;
  final String email;
  final String? phone;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
  }) : username_lower = username.toLowerCase(),
       name_lower = name.toLowerCase();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'username_lower': username_lower,
      'name': name,
      'name_lower': name_lower,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? name,
    String? phone,
  }) {
    return AppUser(
      uid: uid,
      username: username,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }
} 