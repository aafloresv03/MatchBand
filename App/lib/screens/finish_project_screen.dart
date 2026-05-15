import 'package:flutter/material.dart';

import '../services/match_services.dart';
import '../services/project_service.dart';

class FinishProjectScreen extends StatefulWidget {
  final String proposalId;
  final String matchId;
  final List<String> collaborators;

  const FinishProjectScreen({
    super.key,
    this.proposalId = "",
    required this.matchId,
    required this.collaborators,
  });

  @override
  State<FinishProjectScreen> createState() => _FinishProjectScreenState();
}

class _FinishProjectScreenState extends State<FinishProjectScreen> {
  final projectService = ProjectService();
  final matchService = MatchService();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final spotifyController = TextEditingController();
  final youtubeController = TextEditingController();

  bool isLoading = false;

  String? selectedCover;

  final selectedGenres = <String>[];

  final genres = [
    "Rock",
    "Indie Rock",
    "Pop",
    "Hip Hop",
    "Trap",
    "Jazz",
    "Blues",
    "R&B",
    "Soul",
    "Funk",
    "Electrónica",
    "Lo-Fi",
    "Metal",
    "Punk",
    "Flamenco",
    "Acústico",
  ];

  final covers = [
    "https://images.unsplash.com/photo-1511379938547-c1f69419868d?q=80&w=1200&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?q=80&w=1200&auto=format&fit=crop",
    "https://images.unsplash.com/photo-1501386761578-eac5c94b800a?q=80&w=1200&auto=format&fit=crop",
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    spotifyController.dispose();
    youtubeController.dispose();
    super.dispose();
  }

  void toggleGenre(String genre) {
    setState(() {
      selectedGenres.contains(genre)
          ? selectedGenres.remove(genre)
          : selectedGenres.add(genre);
    });
  }

  Future<void> publishProject() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || selectedGenres.isEmpty) {
      showError("Completa título, descripción y al menos un género.");
      return;
    }

    try {
      setState(() => isLoading = true);

      await projectService.createProject(
        title: title,
        description: description,
        genres: selectedGenres,
        matchId: widget.matchId,
        collaborators: widget.collaborators,
        coverImage: selectedCover,
        spotifyUrl: spotifyController.text.trim(),
        youtubeUrl: youtubeController.text.trim(),
      );

      await matchService.updateMatchStatus(
        matchId: widget.matchId,
        status: "finished",
      );

      if (widget.proposalId.isNotEmpty) {
        await matchService.updateProposalStatus(
          proposalId: widget.proposalId,
          status: "finished",
        );
      }

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              "Proyecto publicado",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: const Text(
              "La colaboración se ha finalizado correctamente y el proyecto ya está disponible en Explora.",
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // cierra diálogo
                  Navigator.pop(context, true); // vuelve atrás
                },
                child: const Text(
                  "Ver en Explora",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showError("No se pudo publicar el proyecto.");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    selectedCover ??= covers.first;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Finalizar proyecto"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            22,
            22,
            22,
            MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Publicar proyecto",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Completa los datos finales de la colaboración para publicarla en Explora.",
                style: TextStyle(
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              _InputField(
                controller: titleController,
                label: "Título",
                hint: "Ej: Midnight Echoes",
              ),

              const SizedBox(height: 18),

              _InputField(
                controller: descriptionController,
                label: "Descripción",
                hint: "Describe el proyecto, estilo y resultado final.",
                maxLines: 5,
              ),

              const SizedBox(height: 24),

              const Text(
                "Géneros",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: genres.map((genre) {
                  final selected = selectedGenres.contains(genre);

                  return GestureDetector(
                    onTap: () => toggleGenre(genre),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.orange
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.orange : Colors.white10,
                        ),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              const Text(
                "Portada",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              Column(
                children: covers.map((cover) {
                  final selected = selectedCover == cover;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCover = cover;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected ? Colors.orange : Colors.transparent,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(cover),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              _InputField(
                controller: spotifyController,
                label: "Spotify URL opcional",
                hint: "https://open.spotify.com/...",
              ),

              const SizedBox(height: 18),

              _InputField(
                controller: youtubeController,
                label: "YouTube URL opcional",
                hint: "https://youtube.com/...",
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : publishProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Publicar en Explora",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}