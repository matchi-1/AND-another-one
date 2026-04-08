import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _buildHiddenEmail(String usernameLower) {
    return '$usernameLower@andanotherone.game';
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final usernameTrimmed = username.trim();
    final usernameLower = usernameTrimmed.toLowerCase();
    final email = _buildHiddenEmail(usernameLower);

    final usernameRef = _firestore.collection('usernames').doc(usernameLower);

    final existingUsername = await usernameRef.get();
    if (existingUsername.exists) {
      throw FirebaseAuthException(
        code: 'username-taken',
        message: 'Username already taken.',
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'User creation failed.',
      );
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final usernameSnap = await transaction.get(usernameRef);

        if (usernameSnap.exists) {
          throw FirebaseAuthException(
            code: 'username-taken',
            message: 'Username already taken.',
          );
        }

        final userRef = _firestore.collection('users').doc(user.uid);
        final leaderboardRef = _firestore
            .collection('leaderboards')
            .doc('global')
            .collection('entries')
            .doc(user.uid);

        transaction.set(userRef, {
          'username': usernameTrimmed,
          'usernameLower': usernameLower,
          'email': email,
          'totalXp': 0,
          'dailyXp': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(usernameRef, {
          'uid': user.uid,
        });

        transaction.set(leaderboardRef, {
          'username': usernameTrimmed,
          'score': 0,
          'xp': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      await user.delete();
      rethrow;
    }
  }

  Future<void> loginWithUsername({
    required String username,
    required String password,
  }) async {
    final usernameLower = username.trim().toLowerCase();
    final email = _buildHiddenEmail(usernameLower);

    final doc = await _firestore.collection('usernames').doc(usernameLower).get();

    if (!doc.exists) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Username not found.',
      );
    }

    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password.trim(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}