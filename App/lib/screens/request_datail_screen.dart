import 'package:flutter/material.dart';

import '../services/match_services.dart';
import 'cancel_colaboration_screen.dart';
import 'finish_project_screen.dart';

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> proposal;
  final String alias;

  const RequestDetailScreen({
    super.key,
    required this.proposal,
    required this.alias,
  });

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final matchService = MatchService();

  bool isLoading = false;
  late String status;

  @override
  void initState() {
    super.initState();
    status = widget.proposal["status"] ?? "pending";
  }

  Future<void> startProject() async {
    try {
      setState(() {
        isLoading = true;
      });

      await matchService.startProjectFromProposal(
        proposalId: widget.proposal["id"],
        fromUserId: widget.proposal["fromUserId"],
        toUserId: widget.proposal["toUserId"],
      );

      if (!mounted) return;

      setState(() {
        status = "accepted";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Proyecto iniciado. Ahora aparece en matches abiertos."),
          backgroundColor: Colors.orange,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> rejectProposal() async {
    try {
      setState(() {
        isLoading = true;
      });

      await matchService.updateProposalStatus(
        proposalId: widget.proposal["id"],
        status: "rejected",
      );

      if (!mounted) return;

      setState(() {
        status = "rejected";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Propuesta rechazada."),
          backgroundColor: Colors.redAccent,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      showError("No se pudo rechazar la propuesta.");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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

  String statusLabel(String value) {
    switch (value) {
      case "pending":
        return "Pendiente";
      case "accepted":
        return "Proyecto iniciado";
      case "rejected":
        return "Rechazada";
      case "cancelled":
        return "Cancelada";
      default:
        return value;
    }
  }

  Color statusColor(String value) {
    switch (value) {
      case "accepted":
        return Colors.greenAccent;
      case "rejected":
      case "cancelled":
        return Colors.redAccent;
      case "pending":
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.proposal["message"] ?? "";
    final type = widget.proposal["type"] ?? "proposal";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Detalle de solicitud"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.alias,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                statusLabel(status),
                style: TextStyle(
                  color: statusColor(status),
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  type == "match" ? "Match mutuo" : "Propuesta directa",
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                "Mensaje recibido",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (status == "pending") ...[
                _ActionButton(
                  label: "Empezar proyecto",
                  color: Colors.orange,
                  loading: isLoading,
                  onTap: startProject,
                ),

                const SizedBox(height: 14),

                _ActionButton(
                  label: "Rechazar propuesta",
                  color: Colors.redAccent,
                  outlined: true,
                  loading: isLoading,
                  onTap: rejectProposal,
                ),
              ],

              if (status == "accepted") ...[
                _ActionButton(
                  label: "Finalizar y publicar proyecto",
                  color: Colors.orange,
                  loading: isLoading,
                  onTap: () async {
                    final matchId = "${widget.proposal["fromUserId"]}_${widget.proposal["toUserId"]}";

                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FinishProjectScreen(
                          proposalId: widget.proposal["id"],
                          matchId: matchId,
                          collaborators: [
                            widget.proposal["fromUserId"],
                            widget.proposal["toUserId"],
                          ],
                        ),
                      ),
                    );

                    if (updated == true && mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),

                const SizedBox(height: 14),

                _ActionButton(
                  label: "Cancelar colaboración",
                  color: Colors.redAccent,
                  outlined: true,
                  loading: isLoading,
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CancelCollaborationScreen(
                          proposalId: widget.proposal["id"],
                        ),
                      ),
                    );

                    if (updated == true && mounted) {
                      setState(() {
                        status = "cancelled";
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;
  final bool loading;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: outlined
          ? OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator()
            : Text(label),
      )
          : ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator(
          color: Colors.white,
        )
            : Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}