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
    String? matchId,
    List<String>? collaborators,
    String? coverImage,
    String? spotifyUrl,
    String? youtubeUrl,
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
      "matchId": matchId,
      "collaborators": collaborators ?? [user.uid],
      "coverImage": coverImage ??
          "https://images.unsplash.com/photo-1511379938547-c1f69419868d?q=80&w=1200&auto=format&fit=crop",
      "spotifyUrl": spotifyUrl ?? "",
      "youtubeUrl": youtubeUrl ?? "",
      "status": "published",
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

  Future<bool> hasUserVotedProject(String projectId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No hay usuario autenticado.");
    }

    final voteId = "${user.uid}_$projectId";

    final doc = await _db.collection("project_votes").doc(voteId).get();

    return doc.exists;
  }

  Future<void> voteProject(String projectId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("No hay usuario autenticado.");
    }

    final voteId = "${user.uid}_$projectId";
    final voteRef = _db.collection("project_votes").doc(voteId);
    final projectRef = _db.collection("projects").doc(projectId);

    await _db.runTransaction((transaction) async {
      final voteDoc = await transaction.get(voteRef);

      if (voteDoc.exists) {
        throw Exception("Ya has votado este proyecto.");
      }

      final projectDoc = await transaction.get(projectRef);

      if (!projectDoc.exists) {
        throw Exception("El proyecto no existe.");
      }

      transaction.set(voteRef, {
        "projectId": projectId,
        "userId": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      transaction.update(projectRef, {
        "votes": FieldValue.increment(1),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    });
  }
}