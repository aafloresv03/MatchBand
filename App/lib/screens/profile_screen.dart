import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/user_services.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tag_widget.dart';

import 'auth_gate.dart';
import 'edit_profile_screen.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'requests_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userService = UserService();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final userData = await userService.getCurrentUserData();

    if (userData != null) {
      OnboardingData.artistAlias = userData.artistAlias;
      OnboardingData.description = userData.description;
      OnboardingData.contactMethod = userData.contactMethod;
      OnboardingData.instruments = userData.instruments;
      OnboardingData.genres = userData.genres;
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  String valueOrDefault(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value;
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
          (route) => false,
    );
  }

  void goToTab(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ExploreScreen()),
      );
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RequestsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        bottomNavigationBar: BottomNav(
          currentIndex: 3,
          onTap: goToTab,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
      );
    }

    final artistAlias = valueOrDefault(
      OnboardingData.artistAlias,
      "RiffSombra",
    );

    final description = valueOrDefault(
      OnboardingData.description,
      "Perfil musical de MatchBand.",
    );

    final contactMethod = valueOrDefault(
      OnboardingData.contactMethod,
      "Sin contacto público",
    );

    final instruments = OnboardingData.instruments;
    final genres = OnboardingData.genres;

    return Scaffold(
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
        onTap: goToTab,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Perfil",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: const Color(0xFF1E1E1E),
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.orange,
                    ),
                    onSelected: (value) async {
                      if (value == "edit") {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );

                        if (updated == true && context.mounted) {
                          await loadProfileData();
                        }
                      }

                      if (value == "image") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Función pendiente: imagen de perfil."),
                          ),
                        );
                      }

                      if (value == "privacy") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Función pendiente: privacidad."),
                          ),
                        );
                      }

                      if (value == "logout") {
                        _showLogoutDialog(context);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: "edit",
                        child: Text("Editar perfil"),
                      ),
                      PopupMenuItem(
                        value: "image",
                        child: Text("Imagen de perfil"),
                      ),
                      PopupMenuItem(
                        value: "privacy",
                        child: Text("Privacidad"),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: "logout",
                        child: Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Container(
                height: 390,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1516280440614-37939bbacd81?q=80&w=1200&auto=format&fit=crop",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(.05),
                        Colors.black.withOpacity(.25),
                        Colors.black.withOpacity(.98),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artistAlias,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (genres.isEmpty)
                            const TagWidget(text: "Sin géneros")
                          else
                            ...genres.map(
                                  (genre) => TagWidget(text: genre),
                            ),

                          if (instruments.isNotEmpty)
                            TagWidget(
                              text: instruments.first["name"] ?? "Instrumento",
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              _InfoBox(
                title: "Método de contacto",
                value: contactMethod,
                icon: Icons.alternate_email,
              ),

              const SizedBox(height: 28),

              const Text(
                "Instrumentos",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              if (instruments.isEmpty)
                const _InfoBox(
                  title: "Sin instrumentos añadidos",
                  value: "Completa el onboarding para mostrar tus instrumentos.",
                  icon: Icons.music_note,
                )
              else
                ...instruments.map(
                      (instrument) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _InstrumentCard(
                      name: instrument["name"] ?? "Instrumento",
                      experience: instrument["experience"] ?? "Sin experiencia",
                      learningMethod:
                      instrument["learningMethod"] ?? "Sin método indicado",
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              const Text(
                "Géneros",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              if (genres.isEmpty)
                const _InfoBox(
                  title: "Sin géneros añadidos",
                  value: "Completa el onboarding para mostrar tus géneros.",
                  icon: Icons.library_music,
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: genres
                      .map(
                        (genre) => TagWidget(text: genre),
                  )
                      .toList(),
                ),

              const SizedBox(height: 28),

              const Text(
                "Actividad",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              const Row(
                children: [
                  _StatBox(
                    value: "0",
                    label: "Colabs",
                  ),
                  SizedBox(width: 12),
                  _StatBox(
                    value: "0",
                    label: "Proyectos",
                  ),
                  SizedBox(width: 12),
                  _StatBox(
                    value: "-",
                    label: "Rating",
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Proyecto destacado",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 16),

              _FeaturedProjectCard(
                artistAlias: artistAlias,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Cerrar sesión",
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            "¿Seguro que quieres salir de tu cuenta?",
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                logout(context);
              },
              child: const Text(
                "Cerrar sesión",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  final String name;
  final String experience;
  final String learningMethod;

  const _InstrumentCard({
    required this.name,
    required this.experience,
    required this.learningMethod,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoBox(
      title: name,
      value: "Experiencia: $experience\nAprendizaje: $learningMethod",
      icon: Icons.music_note,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.orange,
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

                const SizedBox(height: 8),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
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

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withOpacity(.05),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProjectCard extends StatelessWidget {
  final String artistAlias;

  const _FeaturedProjectCard({
    required this.artistAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: NetworkImage(
            "https://images.unsplash.com/photo-1511379938547-c1f69419868d?q=80&w=1200&auto=format&fit=crop",
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(.9),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Primer proyecto",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              artistAlias,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}