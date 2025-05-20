import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteChat {
  final String id;
  final String category;
  final String preview;
  final String userMessage;
  final String aiResponse;
  final DateTime createdAt;
  final String userId;
  final bool isDeleted;

  FavoriteChat({
    required this.id,
    required this.category,
    required this.preview,
    required this.userMessage,
    required this.aiResponse,
    required this.createdAt,
    required this.userId,
    this.isDeleted = false,
  });

  // Firestore'dan veri oluşturma
  factory FavoriteChat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteChat(
      id: doc.id,
      category: data['category'] ?? 'Genel',
      preview: data['preview'] ?? '',
      userMessage: data['userMessage'] ?? '',
      aiResponse: data['aiResponse'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: data['userId'] ?? '',
      isDeleted: data['isDeleted'] ?? false,
    );
  }

  // Firestore'a veri gönderme
  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'preview': preview,
      'userMessage': userMessage,
      'aiResponse': aiResponse,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'isDeleted': isDeleted,
    };
  }
} 