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
      final userId = await _authService.signUp(email, password);
      if (userId != null) {
        final newUser = User(
          id: userId,
          name: name,
          email: email,
          password:
              password, // IMPORTANT: Handle passwords securely in production. DO NOT store plain text passwords in Firestore.
          height: height,
          weight: weight,
        );
        await _userRepository.createUser(newUser);
      }
    } catch (e) {
      // Handle signup errors. Consider showing a SnackBar or dialog.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      rethrow; // Re-throw the exception so the caller can also handle it if needed.
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
      return await _userRepository.getUser(id);
    } catch (e) {
      rethrow;
    }
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
