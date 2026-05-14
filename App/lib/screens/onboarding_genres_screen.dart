import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/user_services.dart';

import 'home_screen.dart';

class OnboardingGenresScreen extends StatefulWidget {
  const OnboardingGenresScreen({super.key});

  @override
  State<OnboardingGenresScreen> createState() =>
      _OnboardingGenresScreenState();
}

class _OnboardingGenresScreenState extends State<OnboardingGenresScreen> {
  String? selectedGenre;
  bool isLoading = false;

  final userService = UserService();
  final List<String> selectedGenres = [];

  final List<String> genres = [
    "Rock",
    "Indie Rock",
    "Pop",
    "Indie Pop",
    "Jazz",
    "Blues",
    "Folk",
    "Lo-Fi",
    "Hip Hop",
    "Trap",
    "Reggaeton",
    "Electrónica",
    "Synthwave",
    "Metal",
    "Punk",
    "Clásica",
    "R&B",
    "Soul",
    "Funk",
  ];

  void addGenre() {
    if (selectedGenre == null) {
      showError("Selecciona un género.");
      return;
    }

    if (selectedGenres.contains(selectedGenre)) {
      showError("Ese género ya está añadido.");
      return;
    }

    setState(() {
      selectedGenres.add(selectedGenre!);
      selectedGenre = null;
    });
  }

  void removeGenre(String genre) {
    setState(() {
      selectedGenres.remove(genre);
    });
  }

  Future<void> finishOnboarding() async {
    if (selectedGenres.isEmpty) {
      showError("Añade al menos un género.");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      OnboardingData.genres = selectedGenres;

      await userService.saveOnboardingData();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      showError("No se pudieron guardar los datos.");
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
        title: const Text("Géneros"),
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
                      "Paso 3 de 3",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Tus géneros musicales",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Añade los géneros que tocas, produces o que te interesan para colaborar.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 34),

                    const Text(
                      "Género musical",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: selectedGenre,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E1E1E),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: const Text(
                        "Selecciona un género",
                        style: TextStyle(
                          color: Colors.white38,
                        ),
                      ),
                      items: genres.map((genre) {
                        return DropdownMenuItem<String>(
                          value: genre,
                          child: Text(
                            genre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGenre = value;
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addGenre,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Agregar género",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    if (selectedGenres.isNotEmpty) ...[
                      const Text(
                        "Géneros añadidos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: selectedGenres.map((genre) {
                          return _GenreChip(
                            genre: genre,
                            onDelete: isLoading ? null : () => removeGenre(genre),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),
                    ],

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : finishOnboarding,
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
                          "Finalizar",
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

class _GenreChip extends StatelessWidget {
  final String genre;
  final VoidCallback? onDelete;

  const _GenreChip({
    required this.genre,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 14,
        right: 8,
        top: 10,
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              genre,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close,
              color: Colors.white54,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}