import 'package:flutter/material.dart';
import 'package:nutritrack/data/models/user.dart';
import 'auth_service.dart';
import '../../data/reposotories/user_repository.dart';

class UserService {
  final AuthService _authService;
  final UserRepository _userRepository;

  UserService(this._authService, this._userRepository);

  Future<void> registerUser(BuildContext context, String email, String password,
      String name, double height, double weight) async {
    try {
      // Step 1: Sign up the user
      String? userId;
      try {
        userId = await _authService.signUp(email, password);
        if (userId == null) throw Exception("User ID is null after sign up");
      } catch (e) {
        print("Error during sign-up: $e");
        throw Exception("Error in signUp: $e");
      }

      // Step 2: Create user in Firestore
      try {
        final newUser = User(
          id: userId,
          name: name,
          email: email,
          password: password,
          height: height,
          weight: weight,
        );
        print("creating...");
        print(newUser.name);
        print(newUser.height);
        await _userRepository.createUser(newUser);
        print("finished creating.");
      } catch (e) {
        print("Error during Firestore user creation: $e");
        throw Exception("Error in createUser: $e");
      }
    } catch (e) {
      // Log and rethrow the error for the caller
      print("registerUser encountered an error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      rethrow;
    }
  }

  Future<String?> signInUser(
      BuildContext context, String email, String password) async {
    try {
      return await _authService.signIn(email, password);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      rethrow;
    }
  }

  Future<void> updateUser(
      BuildContext context, User user, Map<String, Object?> updatedUser) async {
    try {
      await _userRepository.updateUser(user, updatedUser);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      rethrow;
    }
  }

  Future<User?> getUser(String id) async {
    try {
      final userData = await _userRepository.getUser(id);
      return userData;
    } catch (e) {
      print("Error getting user: $e");
      rethrow;
    }
  }

  Stream<User?> getUserStream(String userId) {
    return _userRepository.getUserStream(userId);
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      rethrow;
    }
  }
}
