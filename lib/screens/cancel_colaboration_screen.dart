import 'package:flutter/material.dart';

import '../services/match_services.dart';

class CancelCollaborationScreen extends StatefulWidget {
  final String proposalId;

  const CancelCollaborationScreen({
    super.key,
    required this.proposalId,
  });

  @override
  State<CancelCollaborationScreen> createState() =>
      _CancelCollaborationScreenState();
}

class _CancelCollaborationScreenState extends State<CancelCollaborationScreen> {
  final detailsController = TextEditingController();
  final matchService = MatchService();

  String? selectedReason;
  bool isLoading = false;

  final reasons = [
    "No hubo respuesta",
    "No encajaba el estilo",
    "No se llegó a un acuerdo",
    "Falta de tiempo",
    "Otro motivo",
  ];

  Future<void> cancelCollaboration() async {
    if (selectedReason == null) return;

    setState(() => isLoading = true);

    await matchService.updateProposalStatus(
      proposalId: widget.proposalId,
      status: "cancelled",
    );

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Cancelar colaboración"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Motivo de cancelación",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: selectedReason,
                dropdownColor: const Color(0xFF1E1E1E),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text("Selecciona un motivo"),
                items: reasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedReason = value);
                },
              ),

              const SizedBox(height: 20),

              TextField(
                controller: detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Detalles opcionales...",
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : cancelCollaboration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirmar cancelación"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}