import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_chat.dart';

class FavoritesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<FavoriteChat> _favorites = [];
  List<String> _categories = [
    'Anxiety',
    'Depression',
    'Stress Management',
    'Self-Care',
    'Relationships',
    'Work-Life Balance',
  ];
  bool _isLoading = false;

  List<FavoriteChat> get favorites => _favorites;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  // Kullanıcı favorilerini yükle
  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      _favorites = snapshot.docs
          .map((doc) => FavoriteChat.fromFirestore(doc))
          .toList();
      
    } catch (e) {
      print('Favorileri yüklerken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Belirli bir kategorideki favorileri getir
  List<FavoriteChat> getFavoritesByCategory(String category) {
    return _favorites.where((fav) => fav.category == category).toList();
  }

  // Favori ekle
  Future<void> addFavorite({
    required String category, 
    required String preview, 
    required String userMessage, 
    required String aiResponse
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final newFavorite = FavoriteChat(
        id: '',
        category: category,
        preview: preview,
        userMessage: userMessage,
        aiResponse: aiResponse,
        createdAt: DateTime.now(),
        userId: user.uid,
      );

      final docRef = await _firestore.collection('favorites').add(newFavorite.toFirestore());
      
      // Listeye ekle ve bildir
      _favorites.add(FavoriteChat(
        id: docRef.id,
        category: category,
        preview: preview,
        userMessage: userMessage,
        aiResponse: aiResponse,
        createdAt: DateTime.now(),
        userId: user.uid,
      ));
      
      notifyListeners();
    } catch (e) {
      print('Favori eklerken hata: $e');
      throw e;
    }
  }

  // Favori sil
  Future<void> removeFavorite(String favoriteId) async {
    try {
      // Favorileri tamamen silmek yerine isDeleted flagini true yap
      await _firestore.collection('favorites').doc(favoriteId).update({
        'isDeleted': true
      });
      
      _favorites.removeWhere((fav) => fav.id == favoriteId);
      notifyListeners();
    } catch (e) {
      print('Favori silerken hata: $e');
      throw e;
    }
  }

  // Yeni kategori ekle
  void addCategory(String newCategory) {
    if (!_categories.contains(newCategory)) {
      _categories.add(newCategory);
      notifyListeners();
    }
  }
} 