import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _matchKey(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return "${ids[0]}_${ids[1]}";
  }

  Future<bool> likeUser(String targetUserId) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Usuario no autenticado.");
    }

    final currentUserId = currentUser.uid;

    if (currentUserId == targetUserId) {
      throw Exception("No puedes darte like a ti mismo.");
    }

    final existingLike = await _db
        .collection("likes")
        .where("fromUserId", isEqualTo: currentUserId)
        .where("toUserId", isEqualTo: targetUserId)
        .limit(1)
        .get();

    if (existingLike.docs.isNotEmpty) {
      return false;
    }

    await _db.collection("likes").add({
      "fromUserId": currentUserId,
      "toUserId": targetUserId,
      "createdAt": FieldValue.serverTimestamp(),
    });

    final reverseLike = await _db
        .collection("likes")
        .where("fromUserId", isEqualTo: targetUserId)
        .where("toUserId", isEqualTo: currentUserId)
        .limit(1)
        .get();

    if (reverseLike.docs.isEmpty) {
      return false;
    }

    await _createProposalIfNeeded(
      fromUserId: targetUserId,
      toUserId: currentUserId,
      message: "Ha habido match. Puedes empezar una colaboración.",
      type: "match",
    );

    return true;
  }

  Future<void> sendProposal({
    required String receiverUserId,
    required String message,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Usuario no autenticado.");
    }

    await _createProposalIfNeeded(
      fromUserId: currentUser.uid,
      toUserId: receiverUserId,
      message: message,
      type: "proposal",
    );
  }

  Future<void> _createProposalIfNeeded({
    required String fromUserId,
    required String toUserId,
    required String message,
    required String type,
  }) async {
    final existingProposal = await _db
        .collection("proposals")
        .where("fromUserId", isEqualTo: fromUserId)
        .where("toUserId", isEqualTo: toUserId)
        .where("status", isEqualTo: "pending")
        .limit(1)
        .get();

    if (existingProposal.docs.isNotEmpty) {
      return;
    }

    await _db.collection("proposals").add({
      "fromUserId": fromUserId,
      "toUserId": toUserId,
      "message": message,
      "type": type,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> startProjectFromProposal({
    required String proposalId,
    required String fromUserId,
    required String toUserId,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Usuario no autenticado.");
    }

    final activeMatches = await _db
        .collection("matches")
        .where("users", arrayContains: currentUser.uid)
        .where("status", isEqualTo: "active")
        .get();

    if (activeMatches.docs.length >= 3) {
      throw Exception("Has alcanzado el límite de 3 proyectos activos.");
    }

    final matchId = _matchKey(fromUserId, toUserId);
    final matchDoc = await _db.collection("matches").doc(matchId).get();

    if (!matchDoc.exists) {
      await _db.collection("matches").doc(matchId).set({
        "id": matchId,
        "users": [fromUserId, toUserId],
        "userA": fromUserId,
        "userB": toUserId,
        "proposalId": proposalId,
        "status": "active",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    await _db.collection("proposals").doc(proposalId).update({
      "status": "accepted",
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getReceivedProposals() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Usuario no autenticado.");
    }

    final snapshot = await _db
        .collection("proposals")
        .where("toUserId", isEqualTo: currentUser.uid)
        .where("status", isEqualTo: "pending")
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getUserMatches() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Usuario no autenticado.");
    }

    final snapshot = await _db
        .collection("matches")
        .where("users", arrayContains: currentUser.uid)
        .where("status", isEqualTo: "active")
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<void> updateProposalStatus({
    required String proposalId,
    required String status,
  }) async {
    await _db.collection("proposals").doc(proposalId).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMatchStatus({
    required String matchId,
    required String status,
  }) async {
    await _db.collection("matches").doc(matchId).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> passUser(String targetUserId) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("Usuario no autenticado.");
    }

    final currentUserId = currentUser.uid;

    final existingPass = await _db
        .collection("passes")
        .where("fromUserId", isEqualTo: currentUserId)
        .where("toUserId", isEqualTo: targetUserId)
        .limit(1)
        .get();

    if (existingPass.docs.isNotEmpty) {
      return;
    }

    await _db.collection("passes").add({
      "fromUserId": currentUserId,
      "toUserId": targetUserId,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}