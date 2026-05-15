import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String ownerUserId;
  final String artistAlias;
  final String title;
  final String description;
  final List<String> genres;
  final List<String> collaborators;
  final int votes;
  final String coverImage;
  final String spotifyUrl;
  final String youtubeUrl;
  final String status;
  final DateTime? createdAt;

  Project({
    required this.id,
    required this.ownerUserId,
    required this.artistAlias,
    required this.title,
    required this.description,
    required this.genres,
    required this.collaborators,
    required this.votes,
    required this.coverImage,
    required this.spotifyUrl,
    required this.youtubeUrl,
    required this.status,
    required this.createdAt,
  });

  factory Project.fromMap(String id, Map<String, dynamic> data) {
    return Project(
      id: id,
      ownerUserId: data["ownerUserId"]?.toString() ?? "",
      artistAlias: data["artistAlias"]?.toString() ?? "",
      title: data["title"]?.toString() ?? "",
      description: data["description"]?.toString() ?? "",
      genres: List<String>.from(data["genres"] ?? []),
      collaborators: List<String>.from(data["collaborators"] ?? []),
      votes: data["votes"] ?? 0,
      coverImage: data["coverImage"]?.toString() ??
          "https://images.unsplash.com/photo-1511379938547-c1f69419868d?q=80&w=1200&auto=format&fit=crop",
      spotifyUrl: data["spotifyUrl"]?.toString() ?? "",
      youtubeUrl: data["youtubeUrl"]?.toString() ?? "",
      status: data["status"]?.toString() ?? "published",
      createdAt: data["createdAt"] is Timestamp
          ? (data["createdAt"] as Timestamp).toDate()
          : null,
    );
  }
}