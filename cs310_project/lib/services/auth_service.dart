import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile
      await result.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _createUserDocument(result.user!, displayName);

      return result;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      await _updateLastLogin(result.user!);

      return result;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Update user display name
  Future<void> updateDisplayName(String newName) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update in Firebase Auth
        await user.updateDisplayName(newName);
        
        // Update in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': newName,
        });
      } else {
        throw 'No authenticated user found';
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Change user password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        // Reauthenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        
        // Verify old password by reauthenticating
        await user.reauthenticateWithCredential(credential);
        
        // Change password
        await user.updatePassword(newPassword);
      } else {
        throw 'No authenticated user found';
      }
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String displayName) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  // Update last login timestamp
  Future<void> _updateLastLogin(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'Email is already in use.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Email address is invalid.';
        case 'requires-recent-login':
          return 'Please log in again before changing your password.';
        default:
          return 'An error occurred. Please try again. (${e.code})';
      }
    }
    return 'An unexpected error occurred: $e';
  }
} 