import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutritrack/data/models/health_profile.dart';

class HealthRepository {
  final FirebaseFirestore _firestore;

  HealthRepository(this._firestore);

  Future<void> createOrUpdateHealthProfile(HealthProfile profile) async {
    try {
      await _firestore
          .collection('health_profiles')
          .doc(profile.id)
          .set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to update health profile: $e');
    }
  }

  Future<HealthProfile?> getHealthProfile(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('health_profiles')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return HealthProfile.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get health profile: $e');
    }
  }

  Future<void> updateHealthGoals(String profileId, List<String> goals) async {
    try {
      await _firestore
          .collection('health_profiles')
          .doc(profileId)
          .update({'healthGoals': goals});
    } catch (e) {
      throw Exception('Failed to update health goals: $e');
    }
  }

  Future<void> updateDietaryRestrictions(
      String profileId, List<String> restrictions) async {
    try {
      await _firestore
          .collection('health_profiles')
          .doc(profileId)
          .update({'dietaryRestrictions': restrictions});
    } catch (e) {
      throw Exception('Failed to update dietary restrictions: $e');
    }
  }
}
