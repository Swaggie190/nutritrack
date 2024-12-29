import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore;

  ChatService(this._firestore);

  Future<void> sendMessage(String userId, String message) async {
    try {
      await _firestore.collection('chats').add({
        'userId': userId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isUser': true,
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<QuerySnapshot> getMessages(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendFile(String userId, String fileUrl, String fileType) async {
    try {
      await _firestore.collection('chats').add({
        'userId': userId,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'timestamp': FieldValue.serverTimestamp(),
        'isUser': true,
      });
    } catch (e) {
      throw Exception('Failed to send file: $e');
    }
  }
}
