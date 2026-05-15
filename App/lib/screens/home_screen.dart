import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/match_services.dart';
import '../services/user_services.dart';
import '../widgets/action_button.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/tag_widget.dart';

import 'explore_screen.dart';
import 'profile_screen.dart';
import 'proposal_screen.dart';
import 'requests_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userService = UserService();
  final matchService = MatchService();

  List<AppUser> users = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedUsers = await userService.getAvailableUsers();

      if (!mounted) return;

      setState(() {
        users = loadedUsers;
        currentIndex = 0;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        users = [];
        currentIndex = 0;
        isLoading = false;
      });

      showError("No se pudieron cargar los músicos.");
    }
  }

  void removeCurrentProfile() {
    if (users.isEmpty) return;

    setState(() {
      users.removeAt(currentIndex);

      if (users.isEmpty) {
        currentIndex = 0;
        return;
      }

      if (currentIndex >= users.length) {
        currentIndex = 0;
      }
    });
  }

  Future<void> passProfile() async {
    if (users.isEmpty) return;

    final targetUser = users[currentIndex];

    try {
      await matchService.passUser(targetUser.uid);
      removeCurrentProfile();
    } catch (e) {
      showError("No se pudo descartar el perfil.");
    }
  }

  Future<void> likeProfile() async {
    if (users.isEmpty) return;

    final targetUser = users[currentIndex];

    try {
      final hasMatch = await matchService.likeUser(targetUser.uid);

      if (!mounted) return;

      if (hasMatch) {
        showMatchDialog(targetUser);
      } else {
        removeCurrentProfile();
      }
    } catch (e) {
      showError("No se pudo enviar el like.");
    }
  }

  void showMatchDialog(AppUser user) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "¡Match!",
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            "Tú y ${user.artistAlias} estáis interesados en colaborar.",
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                removeCurrentProfile();
              },
              child: const Text(
                "Seguir explorando",
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openProposal(user);
                removeCurrentProfile();
              },
              child: const Text(
                "Enviar propuesta",
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
  }

  void openProposal(AppUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProposalScreen(
          projectName: user.artistAlias,
          receiverUserId: user.uid,
        ),
      ),
    );
  }

  void goToTab(int index) {
    if (index == 0) {
      loadUsers();
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

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  void showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        bottomNavigationBar: BottomNav(
          currentIndex: 0,
          onTap: goToTab,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
      );
    }

    if (users.isEmpty) {
      return Scaffold(
        bottomNavigationBar: BottomNav(
          currentIndex: 0,
          onTap: goToTab,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.group_off,
                  color: Colors.orange,
                  size: 54,
                ),
                const SizedBox(height: 20),
                const Text(
                  "No hay músicos disponibles",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Ya has votado todos los perfiles disponibles o todavía no hay más usuarios registrados.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: loadUsers,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "Recargar músicos",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = users[currentIndex];

    final firstInstrument = user.instruments.isNotEmpty
        ? user.instruments.first["name"] ?? "Instrumento"
        : "Instrumento";

    return Scaffold(
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: goToTab,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Inicio",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    onPressed: loadUsers,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const Text(
                "Descubre músicos",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(user.uid),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      image: DecorationImage(
                        image: NetworkImage(user.bannerImage),
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
                            Colors.black.withOpacity(.92),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.orange.withOpacity(.2),
                            backgroundImage: NetworkImage(user.profileImage),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            user.artistAlias.isEmpty
                                ? "Artista sin alias"
                                : user.artistAlias,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            user.description.isEmpty
                                ? "Sin descripción musical."
                                : user.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              "Perfil compatible",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              TagWidget(text: firstInstrument),
                              ...user.genres.take(2).map(
                                    (genre) => TagWidget(text: genre),
                              ),
                            ],
                          ),

                          const SizedBox(height: 26),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ActionButton(
                                icon: Icons.close,
                                color: Colors.white38,
                                onTap: passProfile,
                              ),
                              const SizedBox(width: 20),
                              ActionButton(
                                icon: Icons.favorite,
                                color: Colors.orange,
                                big: true,
                                onTap: likeProfile,
                              ),
                              const SizedBox(width: 20),
                              ActionButton(
                                icon: Icons.mail,
                                color: Colors.white38,
                                onTap: () => openProposal(user),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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