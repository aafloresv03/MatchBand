import 'package:flutter/material.dart';

import '../services/match_services.dart';

class ProposalScreen extends StatefulWidget {
  final String projectName;
  final String receiverUserId;

  const ProposalScreen({
    super.key,
    required this.projectName,
    required this.receiverUserId,
  });

  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  final TextEditingController messageController = TextEditingController();

  final MatchService matchService = MatchService();

  bool isLoading = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendProposal() async {
    final message = messageController.text.trim();

    if (message.isEmpty) {
      showError("Escribe un mensaje antes de enviar la propuesta.");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await matchService.sendProposal(
        receiverUserId: widget.receiverUserId,
        message: message,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              "Propuesta enviada",
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            content: const Text(
              "Tu mensaje se ha enviado correctamente. El destinatario podrá ver tu propuesta en solicitudes.",
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Aceptar",
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
      if (!mounted) return;
      showError("No se pudo enviar la propuesta.");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Enviar propuesta"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                22,
                22,
                22,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.projectName,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Mensaje de colaboración",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Escribe un mensaje claro explicando por qué quieres colaborar. Tus métodos de contacto se mostrarán desde tu perfil.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Mensaje",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: messageController,
                      maxLines: 8,
                      minLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText:
                        "Hola, me interesa colaborar contigo. Creo que mi estilo puede encajar con tu proyecto...",
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : sendProposal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Enviar propuesta",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}