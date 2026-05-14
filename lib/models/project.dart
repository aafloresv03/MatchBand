import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String ownerUserId;
  final String artistAlias;
  final String title;
  final String description;
  final List<String> genres;
  final int votes;
  final DateTime? createdAt;

  Project({
    required this.id,
    required this.ownerUserId,
    required this.artistAlias,
    required this.title,
    required this.description,
    required this.genres,
    required this.votes,
    required this.createdAt,
  });

  factory Project.fromMap(String id, Map<String, dynamic> data) {
    return Project(
      id: id,
      ownerUserId: data["ownerUserId"] ?? "",
      artistAlias: data["artistAlias"] ?? "",
      title: data["title"] ?? "",
      description: data["description"] ?? "",
      genres: List<String>.from(data["genres"] ?? []),
      votes: data["votes"] ?? 0,
      createdAt: data["createdAt"] is Timestamp
          ? (data["createdAt"] as Timestamp).toDate()
          : null,
    );
  }
}