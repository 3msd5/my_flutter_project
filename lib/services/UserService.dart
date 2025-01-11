import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create new user
  Future<void> createUser(AppUser user) async {
    try {
      // Check if username is available first
      final isAvailable = await isUsernameAvailable(user.username);
      if (!isAvailable) {
        throw Exception('Username is already taken');
      }

      // Create user document
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username_lower', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      print('Error checking username availability: $e');
      throw e;
    }
  }

  // Search users by username or name
  Future<List<AppUser>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final queryLower = query.toLowerCase();
      final querySnapshot = await _firestore
          .collection('users')
          .where('username_lower', isGreaterThanOrEqualTo: queryLower)
          .where('username_lower', isLessThan: queryLower + 'z')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get current user
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return AppUser.fromMap(doc.data()!);
    } catch (e) {
      print('Error getting current user: $e');
      throw e;
    }
  }

  // Get user by ID
  Future<AppUser?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return AppUser.fromMap(doc.data()!);
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'name_lower': name.toLowerCase(),
        'phone': phone,
      });
    } catch (e) {
      print('Error updating user profile: $e');
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }
}
