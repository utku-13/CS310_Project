import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    try {
      return _firestore
          .collection('chats')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
    } catch (e) {
      print('Error getting user chats: $e');
      return Stream.value([]);
    }
  }

  // Save a new chat
  Future<String> saveChat(ChatModel chat) async {
    try {
      // Firestore'a kaydetmeden önce basit bir ID oluştur
      final chatData = chat.toFirestore();
      chatData['timestamp'] = FieldValue.serverTimestamp();
      
      DocumentReference docRef = await _firestore.collection('chats').add(chatData);
      return docRef.id;
    } catch (e) {
      print('Error saving chat: $e');
      // Hata durumunda basit bir ID döndür
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      print('Error deleting chat: $e');
      // Hata durumunda sessizce devam et
    }
  }

  // Get a chat by ID
  Future<ChatModel?> getChatById(String chatId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return ChatModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting chat by ID: $e');
      return null;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user data: $e');
      // Hata durumunda sessizce devam et
    }
  }

  // Create a new document in a collection
  Future<String> createDocument(String collection, Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = await _firestore.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error creating document: $e');
      // Hata durumunda basit bir ID döndür
      return DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  // Update a document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error updating document: $e');
      // Hata durumunda sessizce devam et
    }
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      // Hata durumunda sessizce devam et
    }
  }

  // Get documents from a collection
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    try {
      return _firestore.collection(collection).snapshots();
    } catch (e) {
      print('Error getting collection stream: $e');
      return Stream.empty();
    }
  }

  // Get documents with a query
  Stream<QuerySnapshot> getQueryStream(String collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
    try {
      Query query = _firestore.collection(collection);
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      return query.snapshots();
    } catch (e) {
      print('Error getting query stream: $e');
      return Stream.empty();
    }
  }
} 