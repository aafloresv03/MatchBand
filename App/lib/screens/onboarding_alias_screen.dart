import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import 'onboarding_instruments_screen.dart';

class OnboardingAliasScreen extends StatefulWidget {
  const OnboardingAliasScreen({super.key});

  @override
  State<OnboardingAliasScreen> createState() => _OnboardingAliasScreenState();
}

class _OnboardingAliasScreenState extends State<OnboardingAliasScreen> {
  final aliasController = TextEditingController();
  final descriptionController = TextEditingController();
  final contactController = TextEditingController();

  @override
  void dispose() {
    aliasController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    super.dispose();
  }

  void goNext() {
    if (aliasController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    OnboardingData.artistAlias = aliasController.text.trim();
    OnboardingData.description = descriptionController.text.trim();
    OnboardingData.contactMethod = contactController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OnboardingInstrumentsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Perfil artístico"),
        backgroundColor: const Color(0xFF121212),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                28,
                28,
                28,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 56,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Paso 1 de 3",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Define tu identidad",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Estos datos aparecerán en tu perfil y servirán para que otros músicos sepan quién eres y cómo contactar contigo.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 34),

                    _InputField(
                      controller: aliasController,
                      label: "Alias artístico",
                      hint: "Ej: RiffSombra",
                    ),

                    const SizedBox(height: 18),

                    _InputField(
                      controller: descriptionController,
                      label: "Descripción artística",
                      hint: "Cuenta qué tipo de músico eres y qué buscas.",
                      maxLines: 5,
                    ),

                    const SizedBox(height: 18),

                    _InputField(
                      controller: contactController,
                      label: "Método de contacto",
                      hint: "Email, Instagram o alias público",
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 34),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: goNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Continuar",
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

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
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
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }
}