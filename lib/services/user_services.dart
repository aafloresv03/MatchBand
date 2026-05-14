import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/onboarding_data.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveOnboardingData() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No hay usuario autenticado.");
    }

    await _db.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "email": user.email,
      "artistAlias": OnboardingData.artistAlias,
      "description": OnboardingData.description,
      "contactMethod": OnboardingData.contactMethod,
      "instruments": OnboardingData.instruments,
      "genres": OnboardingData.genres,
      "profileCompleted": true,
      "createdAt": FieldValue.serverTimestamp(),
    });

  }

  Future<AppUser?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final doc =
    await _db.collection("users").doc(user.uid).get();

    if (!doc.exists) {
      return null;
    }

    return AppUser.fromMap(doc.data()!);
  }

  Future<List<AppUser>> getAvailableUsers() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("No hay usuario autenticado.");
    }

    final currentUserId = currentUser.uid;

    final usersSnapshot = await _db.collection("users").get();

    final likesSnapshot = await _db
        .collection("likes")
        .where("fromUserId", isEqualTo: currentUserId)
        .get();

    final passesSnapshot = await _db
        .collection("passes")
        .where("fromUserId", isEqualTo: currentUserId)
        .get();

    final likedUserIds = likesSnapshot.docs
        .map((doc) => doc["toUserId"] as String)
        .toSet();

    final passedUserIds = passesSnapshot.docs
        .map((doc) => doc["toUserId"] as String)
        .toSet();

    final votedUserIds = {
      ...likedUserIds,
      ...passedUserIds,
    };

    final availableUsers = usersSnapshot.docs.where((doc) {
      final data = doc.data();

      final userId = data["uid"]?.toString() ?? "";

      if (userId.isEmpty) return false;

      if (userId == currentUserId) return false;

      if (votedUserIds.contains(userId)) return false;

      if (data["profileCompleted"] != true) return false;

      return true;
    }).map((doc) {
      return AppUser.fromMap(doc.data());
    }).toList();

    return availableUsers;
  }

  Future<Map<String, dynamic>?> getUserById(String uid) async {
    final doc = await _db.collection("users").doc(uid).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }

  Future<void> updateProfileBasicData({
    required String artistAlias,
    required String description,
    required String contactMethod,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No hay usuario autenticado.");
    }

    await _db.collection("users").doc(user.uid).update({
      "artistAlias": artistAlias,
      "description": description,
      "contactMethod": contactMethod,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}