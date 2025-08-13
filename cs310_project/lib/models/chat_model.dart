import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String userId;
  final String userMessage;
  final String aiResponse;
  final DateTime timestamp;

  ChatModel({
    required this.id,
    required this.userId,
    required this.userMessage,
    required this.aiResponse,
    required this.timestamp,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userMessage: data['userMessage'] ?? '',
      aiResponse: data['aiResponse'] ?? '',
      timestamp: data['timestamp'] != null 
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
} 