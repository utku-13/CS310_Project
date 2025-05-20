import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's chats
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  // Save a new chat
  Future<String> saveChat(ChatModel chat) async {
    try {
      DocumentReference docRef = await _firestore.collection('chats').add(chat.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error saving chat: $e');
      throw e;
    }
  }

  // Delete a chat (soft delete)
  Future<void> deleteChat(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isDeleted': true,
      });
    } catch (e) {
      print('Error deleting chat: $e');
      throw e;
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
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw e;
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
      throw e;
    }
  }

  // Update a document
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating document: $e');
      throw e;
    }
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      throw e;
    }
  }

  // Get documents from a collection
  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Get documents with a query
  Stream<QuerySnapshot> getQueryStream(String collection, {
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
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
  }
} 