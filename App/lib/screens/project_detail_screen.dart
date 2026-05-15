import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/project.dart';
import '../services/project_service.dart';
import '../widgets/tag_widget.dart';
import 'embedded_media_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final projectService = ProjectService();

  bool isLoadingCollaborators = true;
  bool isCheckingVote = true;
  bool isVoting = false;
  bool hasVoted = false;

  int currentVotes = 0;
  List<String> collaboratorAliases = [];

  @override
  void initState() {
    super.initState();
    currentVotes = widget.project.votes;
    loadCollaborators();
    checkVoteStatus();
  }

  Future<void> loadCollaborators() async {
    final aliases = <String>[];

    for (final uid in widget.project.collaborators) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        aliases.add(data?["artistAlias"]?.toString() ?? "Usuario");
      }
    }

    if (!mounted) return;

    setState(() {
      collaboratorAliases = aliases;
      isLoadingCollaborators = false;
    });
  }

  Future<void> checkVoteStatus() async {
    try {
      final voted = await projectService.hasUserVotedProject(widget.project.id);

      if (!mounted) return;

      setState(() {
        hasVoted = voted;
        isCheckingVote = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCheckingVote = false;
      });
    }
  }

  Future<void> voteProject() async {
    if (hasVoted || isVoting) return;

    try {
      setState(() {
        isVoting = true;
      });

      await projectService.voteProject(widget.project.id);

      if (!mounted) return;

      setState(() {
        hasVoted = true;
        currentVotes++;
        isVoting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Voto registrado correctamente."),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isVoting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se pudo votar este proyecto."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;

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

              const SizedBox(height: 22),

              _VoteBox(
                votes: currentVotes,
                hasVoted: hasVoted,
                isCheckingVote: isCheckingVote,
                isVoting: isVoting,
                onVote: voteProject,
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
                title: "Colaboradores",
                value: isLoadingCollaborators
                    ? "Cargando colaboradores..."
                    : collaboratorAliases.isEmpty
                    ? "Sin colaboradores registrados"
                    : collaboratorAliases.join(" · "),
                icon: Icons.group,
              ),

              if (project.spotifyUrl.isNotEmpty ||
                  project.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 26),

                const Text(
                  "Escuchar proyecto",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),
              ],

              if (project.spotifyUrl.isNotEmpty)
                _MediaPreviewCard(
                  title: "Spotify",
                  subtitle: "Escuchar referencia musical",
                  icon: Icons.music_note,
                  url: project.spotifyUrl,
                ),

              if (project.youtubeUrl.isNotEmpty) ...[
                const SizedBox(height: 14),
                _MediaPreviewCard(
                  title: "YouTube",
                  subtitle: "Ver vídeo del proyecto",
                  icon: Icons.play_circle,
                  url: project.youtubeUrl,
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

class _VoteBox extends StatelessWidget {
  final int votes;
  final bool hasVoted;
  final bool isCheckingVote;
  final bool isVoting;
  final VoidCallback onVote;

  const _VoteBox({
    required this.votes,
    required this.hasVoted,
    required this.isCheckingVote,
    required this.isVoting,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = hasVoted || isCheckingVote || isVoting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasVoted
              ? Colors.greenAccent.withOpacity(.45)
              : Colors.orange.withOpacity(.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.orange,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$votes votos",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasVoted
                      ? "Ya has votado este proyecto."
                      : "Apoya este proyecto dentro de la comunidad.",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: disabled ? null : onVote,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasVoted ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
              hasVoted ? Colors.green.withOpacity(.55) : Colors.white12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isVoting
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              hasVoted ? "Votado" : "Votar",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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

class _MediaPreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String url;

  const _MediaPreviewCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmbeddedMediaScreen(
              title: title,
              url: url,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.orange.withOpacity(.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(.16),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: Colors.orange,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}