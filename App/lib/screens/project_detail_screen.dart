import 'package:flutter/material.dart';

import '../models/project.dart';
import '../widgets/tag_widget.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Proyecto"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.network(
                  project.coverImage,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                project.title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                project.artistAlias,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: project.genres
                    .map((genre) => TagWidget(text: genre))
                    .toList(),
              ),

              const SizedBox(height: 26),

              const Text(
                "Descripción",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                project.description,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 26),

              _InfoBox(
                title: "Votos",
                value: "${project.votes}",
                icon: Icons.favorite,
              ),

              const SizedBox(height: 14),

              _InfoBox(
                title: "Colaboradores",
                value: "${project.collaborators.length}",
                icon: Icons.group,
              ),

              if (project.spotifyUrl.isNotEmpty) ...[
                const SizedBox(height: 14),
                _InfoBox(
                  title: "Spotify",
                  value: project.spotifyUrl,
                  icon: Icons.music_note,
                ),
              ],

              if (project.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 14),
                _InfoBox(
                  title: "YouTube",
                  value: project.youtubeUrl,
                  icon: Icons.play_circle,
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}