import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String boardId({
    required String modeId,
    required String difficultyId,
  }) {
    return '${modeId}_$difficultyId';
  }

  Future<void> submitScore({
    required String modeId,
    required String difficultyId,
    required int score,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final boardKey = boardId(modeId: modeId, difficultyId: difficultyId);

    final userDoc =
    await _firestore.collection('users').doc(uid).get();

    final username = (userDoc.data()?['username'] as String?) ?? 'Unknown';

    final leaderboardRef = _firestore
        .collection('leaderboards')
        .doc(boardKey)
        .collection('entries')
        .doc(uid);

    final userBoardRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('boards')
        .doc(boardKey);

    await _firestore.runTransaction((transaction) async {
      final leaderboardSnap = await transaction.get(leaderboardRef);

      final previousBest = leaderboardSnap.exists
          ? (leaderboardSnap.data()?['bestScore'] as int? ?? 0)
          : 0;

      final newBest = score > previousBest ? score : previousBest;

      transaction.set(
        leaderboardRef,
        {
          'uid': uid,
          'username': username,
          'bestScore': newBest,
          'lastScore': score,
          'gamesPlayed': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      transaction.set(
        userBoardRef,
        {
          'boardId': boardKey,
          'bestScore': newBest,
          'lastScore': score,
          'gamesPlayed': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Stream<List<LeaderboardEntryModel>> streamLeaderboard({
    required String modeId,
    required String difficultyId,
    int limit = 50,
  }) {
    final boardKey = boardId(modeId: modeId, difficultyId: difficultyId);

    return _firestore
        .collection('leaderboards')
        .doc(boardKey)
        .collection('entries')
        .orderBy('bestScore', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => LeaderboardEntryModel.fromMap(doc.data()))
          .toList(),
    );
  }
}

class LeaderboardEntryModel {
  final String uid;
  final String username;
  final int bestScore;
  final int lastScore;
  final int gamesPlayed;

  LeaderboardEntryModel({
    required this.uid,
    required this.username,
    required this.bestScore,
    required this.lastScore,
    required this.gamesPlayed,
  });

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntryModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? 'Unknown',
      bestScore: map['bestScore'] ?? 0,
      lastScore: map['lastScore'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
    );
  }
}