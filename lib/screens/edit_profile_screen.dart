import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/user_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final userService = UserService();

  late final TextEditingController aliasController;
  late final TextEditingController descriptionController;
  late final TextEditingController contactController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    aliasController = TextEditingController(
      text: OnboardingData.artistAlias,
    );

    descriptionController = TextEditingController(
      text: OnboardingData.description,
    );

    contactController = TextEditingController(
      text: OnboardingData.contactMethod,
    );
  }

  @override
  void dispose() {
    aliasController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final alias = aliasController.text.trim();
    final description = descriptionController.text.trim();
    final contact = contactController.text.trim();

    if (alias.isEmpty || description.isEmpty || contact.isEmpty) {
      showError("Completa todos los campos.");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      OnboardingData.artistAlias = alias;
      OnboardingData.description = description;
      OnboardingData.contactMethod = contact;

      await userService.updateProfileBasicData(
        artistAlias: alias,
        description: description,
        contactMethod: contact,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      showError("No se pudo guardar el perfil.");
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
        title: const Text("Editar perfil"),
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
                      "Datos públicos",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Estos datos serán visibles para otros músicos cuando visiten tu perfil o reciban una propuesta.",
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
                      hint: "Cuenta qué tipo de músico eres.",
                      maxLines: 5,
                    ),

                    const SizedBox(height: 18),

                    _InputField(
                      controller: contactController,
                      label: "Método de contacto",
                      hint: "Email, Instagram o alias público",
                    ),

                    const SizedBox(height: 34),

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : saveProfile,
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
                          "Guardar cambios",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
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
            fontSize: 13,
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