import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/onboarding_data.dart';
import '../models/project.dart';

class ProjectService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createProject({
    required String title,
    required String description,
    required List<String> genres,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No hay usuario autenticado.");
    }

    await _db.collection("projects").add({
      "ownerUserId": user.uid,
      "artistAlias": OnboardingData.artistAlias,
      "title": title,
      "description": description,
      "genres": genres,
      "votes": 0,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<Project>> getProjects() async {
    final snapshot = await _db.collection("projects").get();

    return snapshot.docs
        .map((doc) => Project.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Project>> getUserProjects(String userId) async {
    final snapshot = await _db
        .collection("projects")
        .where("ownerUserId", isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => Project.fromMap(doc.id, doc.data()))
        .toList();
  }
}