import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
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
  StreamSubscription<QuerySnapshot>? _favoritesSubscription;

  List<FavoriteChat> get favorites => _favorites;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  // Initialize real-time listener for favorites
  void initializeFavoritesListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    // Cancel any existing subscription
    _favoritesSubscription?.cancel();

    // Set up real-time listener
    _favoritesSubscription = _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _favorites = snapshot.docs
              .map((doc) => FavoriteChat.fromFirestore(doc))
              .toList();
          _isLoading = false;
          notifyListeners();
        }, onError: (error) {
          print('Error listening to favorites: $error');
          _isLoading = false;
          notifyListeners();
        });
  }

  // Clean up subscription when provider is disposed
  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  // Load favorites (now just initializes the listener)
  Future<void> loadFavorites() async {
    initializeFavoritesListener();
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

      await _firestore.collection('favorites').add(newFavorite.toFirestore());
      // No need to manually update _favorites as the listener will handle it
    } catch (e) {
      print('Favori eklerken hata: $e');
      throw e;
    }
  }

  // Favori sil
  Future<void> removeFavorite(String favoriteId) async {
    try {
      await _firestore.collection('favorites').doc(favoriteId).update({
        'isDeleted': true
      });
      // No need to manually update _favorites as the listener will handle it
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