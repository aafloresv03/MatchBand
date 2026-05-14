import 'package:flutter/material.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/tag_widget.dart';

import 'home_screen.dart';
import 'profile_screen.dart';
import 'requests_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topSong = {
      "title": "Midnight Echoes",
      "authors": "Alex Rivera · Lucía Martín",
      "description":
      "Canción indie rock colaborativa creada por músicos de la comunidad MatchBand.",
      "cover":
      "https://images.unsplash.com/photo-1511379938547-c1f69419868d?q=80&w=1200&auto=format&fit=crop",
      "votes": "1.248 votos",
      "genre": "Indie Rock",
    };

    final songs = [
      {
        "title": "Neon Nights",
        "authors": "Neon Collective",
        "votes": "982 votos",
      },
      {
        "title": "Acoustic Room",
        "authors": "Emma Stone · Daniel Ross",
        "votes": "846 votos",
      },
      {
        "title": "Blue Noise",
        "authors": "Carlos Vega",
        "votes": "731 votos",
      },
    ];

    final artists = [
      {
        "name": "Lucía Martín",
        "info": "12 colaboraciones · 4.9★",
      },
      {
        "name": "Daniel Ross",
        "info": "9 colaboraciones · 4.8★",
      },
      {
        "name": "Alex Rivera",
        "info": "8 colaboraciones · 4.7★",
      },
    ];

    return Scaffold(
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const RequestsScreen(),
              ),
            );
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                "Descubre canciones, proyectos destacados y artistas con mayor actividad dentro de MatchBand.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Canción más votada del mes",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              _FeaturedSongCard(song: topSong),

              const SizedBox(height: 30),

              const Text(
                "Top canciones",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              ...songs.asMap().entries.map(
                    (entry) => _RankingSongItem(
                  position: entry.key + 1,
                  title: entry.value["title"]!,
                  authors: entry.value["authors"]!,
                  votes: entry.value["votes"]!,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Artistas destacados",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              ...artists.asMap().entries.map(
                    (entry) => _ArtistRankingItem(
                  position: entry.key + 1,
                  name: entry.value["name"]!,
                  info: entry.value["info"]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedSongCard extends StatelessWidget {
  final Map<String, String> song;

  const _FeaturedSongCard({
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
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
              song["cover"]!,
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
                  song["title"]!,
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
                  song["votes"]!,
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
            song["authors"]!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            song["description"]!,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 14),

          TagWidget(text: song["genre"]!),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                // Próximo paso: navegar a ProjectDetailScreen.
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

class _RankingSongItem extends StatelessWidget {
  final int position;
  final String title;
  final String authors;
  final String votes;

  const _RankingSongItem({
    required this.position,
    required this.title,
    required this.authors,
    required this.votes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  authors,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            votes,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistRankingItem extends StatelessWidget {
  final int position;
  final String name;
  final String info;

  const _ArtistRankingItem({
    required this.position,
    required this.name,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.orange.withOpacity(.16),
            child: Text(
              "$position",
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  info,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.star,
            color: Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }
}