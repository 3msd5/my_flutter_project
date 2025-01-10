import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı adını aramak için
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      List<Map<String, dynamic>> users = [];

      for (var doc in querySnapshot.docs) {
        users.add(doc.data() as Map<String, dynamic>);
      }

      return users;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }
}
