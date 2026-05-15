import 'package:flutter/material.dart';

import '../models/project.dart';
import '../services/project_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tag_widget.dart';

import 'home_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';
import 'project_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final projectService = ProjectService();

  bool isLoading = true;
  List<Project> projects = [];

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final loadedProjects = await projectService.getProjects();

      loadedProjects.sort((a, b) => b.votes.compareTo(a.votes));

      if (!mounted) return;

      setState(() {
        projects = loadedProjects;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void goToTab(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RequestsScreen()),
      );
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topProject = projects.isNotEmpty ? projects.first : null;
    final rankingProjects = projects.length > 1 ? projects.skip(1).toList() : [];

    return Scaffold(
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        onTap: goToTab,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        )
            : RefreshIndicator(
          color: Colors.orange,
          onRefresh: loadProjects,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Explora",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Comunidad",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Descubre proyectos publicados por colaboraciones reales dentro de MatchBand.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                if (projects.isEmpty)
                  const _EmptyState()
                else ...[
                  const Text(
                    "Proyecto destacado",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _FeaturedProjectCard(project: topProject!),

                  const SizedBox(height: 30),

                  const Text(
                    "Top proyectos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (rankingProjects.isEmpty)
                    const _SmallEmptyCard(
                      text: "Todavía no hay más proyectos publicados.",
                    )
                  else
                    ...rankingProjects.asMap().entries.map(
                          (entry) => _RankingProjectItem(
                        position: entry.key + 2,
                        project: entry.value,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedProjectCard extends StatelessWidget {
  final Project project;

  const _FeaturedProjectCard({
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final firstGenre = project.genres.isNotEmpty ? project.genres.first : "Proyecto";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              project.coverImage,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "${project.votes} votos",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            project.artistAlias,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            project.description,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              TagWidget(text: firstGenre),
              if (project.spotifyUrl.isNotEmpty)
                const TagWidget(text: "Spotify"),
              if (project.youtubeUrl.isNotEmpty)
                const TagWidget(text: "YouTube"),
            ],
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailScreen(project: project),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Ver proyecto",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingProjectItem extends StatelessWidget {
  final int position;
  final Project project;

  const _RankingProjectItem({
    required this.position,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(project: project),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  "#$position",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    project.artistAlias,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              "${project.votes}",
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.library_music,
            color: Colors.orange,
            size: 46,
          ),
          SizedBox(height: 16),
          Text(
            "Todavía no hay proyectos publicados",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Cuando una colaboración se finalice correctamente, aparecerá aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallEmptyCard extends StatelessWidget {
  final String text;

  const _SmallEmptyCard({
    required this.text,
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
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
        ),
      ),
    );
  }
}