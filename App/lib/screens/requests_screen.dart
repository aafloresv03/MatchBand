import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/match_services.dart';
import '../services/user_services.dart';
import '../widgets/bottom_nav.dart';

import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'request_datail_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final matchService = MatchService();
  final userService = UserService();

  bool isLoading = true;

  List<Map<String, dynamic>> proposals = [];
  List<Map<String, dynamic>> matches = [];

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    try {
      final loadedProposals = await matchService.getReceivedProposals();
      final loadedMatches = await matchService.getUserMatches();

      setState(() {
        proposals = loadedProposals;
        matches = loadedMatches;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getUserAlias(String uid) async {
    final data = await userService.getUserById(uid);
    return data?["artistAlias"] ?? "Usuario";
  }

  Future<void> changeMatchStatus(String matchId, String status) async {
    await matchService.updateMatchStatus(
      matchId: matchId,
      status: status,
    );

    await loadRequests();
  }

  static Color statusColor(String status) {
    switch (status) {
      case "active":
      case "accepted":
        return Colors.greenAccent;
      case "pending":
        return Colors.orange;
      case "finished":
        return Colors.white38;
      case "cancelled":
      case "rejected":
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  static String statusLabel(String status) {
    switch (status) {
      case "active":
        return "Activo";
      case "accepted":
        return "Aceptada";
      case "pending":
        return "Pendiente";
      case "finished":
        return "Finalizado";
      case "cancelled":
        return "Cancelado";
      case "rejected":
        return "Rechazada";
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        onTap: (index) {
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

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        )
            : RefreshIndicator(
          color: Colors.orange,
          onRefresh: loadRequests,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Solicitudes",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Colaboraciones",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Revisa propuestas recibidas y gestiona tus colaboraciones activas.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Propuestas recibidas",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "${proposals.length}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (proposals.isEmpty)
                  const _EmptyCard(
                    text: "Todavía no tienes propuestas recibidas.",
                  )
                else
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: proposals.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final proposal = proposals[index];

                        return FutureBuilder<String>(
                          future: getUserAlias(proposal["fromUserId"]),
                          builder: (context, snapshot) {
                            final alias =
                                snapshot.data ?? "Cargando...";
                            final status =
                                proposal["status"] ?? "pending";

                            return _CompactProposalCard(
                              alias: alias,
                              status: status,
                              onOpen: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RequestDetailScreen(
                                          proposal: proposal,
                                          alias: alias,
                                        ),
                                  ),
                                );

                                loadRequests();
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 34),

                const Text(
                  "Matches abiertos",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 18),

                if (matches.isEmpty)
                  const _EmptyCard(
                    text: "Todavía no tienes matches activos.",
                  )
                else
                  ...matches.map(
                        (match) {
                      final currentUid =
                          FirebaseAuth.instance.currentUser?.uid;

                      final users =
                      List<String>.from(match["users"] ?? []);

                      final otherUid = users.firstWhere(
                            (uid) => uid != currentUid,
                        orElse: () => "",
                      );

                      return FutureBuilder<String>(
                        future: getUserAlias(otherUid),
                        builder: (context, snapshot) {
                          final alias =
                              snapshot.data ?? "Cargando...";
                          final status =
                              match["status"] ?? "active";

                          return MatchCard(
                            title: alias,
                            statusText: status,
                            statusColor: statusColor(status),
                            onFinish: () => changeMatchStatus(
                              match["id"],
                              "finished",
                            ),
                            onCancel: () => changeMatchStatus(
                              match["id"],
                              "cancelled",
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactProposalCard extends StatelessWidget {
  final String alias;
  final String status;
  final VoidCallback onOpen;

  const _CompactProposalCard({
    required this.alias,
    required this.status,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final color = _RequestsScreenState.statusColor(status);
    final label = _RequestsScreenState.statusLabel(status);

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: 118,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(.65),
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.orange.withOpacity(.16),
                  child: Text(
                    alias.isNotEmpty ? alias[0].toUpperCase() : "?",
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1E1E1E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              alias,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final String title;
  final Color statusColor;
  final String statusText;
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  const MatchCard({
    super.key,
    required this.title,
    required this.statusColor,
    required this.statusText,
    required this.onFinish,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final label = _RequestsScreenState.statusLabel(statusText);
    final isActive = statusText == "active";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: statusColor,
          width: 1.4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (isActive) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Finalizar",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          height: 1.5,
        ),
      ),
    );
  }
}