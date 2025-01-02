import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/data/models/user.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<void> createUser(User user) async {
    try {
      // Save the user document to Firestore
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      print("User created successfully in Firestore: ${user.id}");
    } on FirebaseException catch (e) {
      print("Firestore error during user creation: ${e.message}");
      print("Full error details: ${e.toString()}"); // Log complete error object
      throw Exception('Failed to create user in Firestore: ${e.message}');
    } catch (e) {
      print("Unexpected error during Firestore user creation: $e");
      throw Exception("Unexpected error in createUser: $e");
    }
  }

  Future<User?> getUser(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data()!;
        data['id'] = doc.id;
        return User.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      throw Exception('Failed to get user: $e');
    }
  }

  Stream<User?> getUserStream(String id) {
    return _firestore.collection('users').doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        data['id'] = snapshot.id;
        return User.fromMap(data);
      }
      return null;
    });
  }

  Future<void> updateUser(User user, Map<String, Object?> updatedUser) async {
    try {
      Map<String, dynamic> updateData = user.toMap();
      updateData.remove('id');

      updateData.addAll(updatedUser);

      await _firestore.collection('users').doc(user.id).update(updateData);
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}
