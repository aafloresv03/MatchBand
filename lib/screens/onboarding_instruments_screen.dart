import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import 'onboarding_genres_screen.dart';

class OnboardingInstrumentsScreen extends StatefulWidget {
  const OnboardingInstrumentsScreen({super.key});

  @override
  State<OnboardingInstrumentsScreen> createState() =>
      _OnboardingInstrumentsScreenState();
}

class _OnboardingInstrumentsScreenState
    extends State<OnboardingInstrumentsScreen> {
  String? selectedInstrument;
  String? selectedLearningMethod;
  double experienceValue = 0;

  final List<Map<String, String>> addedInstruments = [];

  final List<String> instruments = [
    "Guitarra",
    "Piano",
    "Batería",
    "Bajo",
    "Voz",
    "Saxofón",
    "Violín",
    "Trompeta",
    "Producción musical",
    "DJ",
  ];

  final List<String> learningMethods = [
    "Autodidacta",
    "Escuela de música",
    "Profesor particular",
    "Familia / amigos",
    "Conservatorio",
    "Online",
    "Experiencia en bandas",
  ];

  String getExperienceLabel() {
    if (experienceValue == 0) return "< 1 año";
    if (experienceValue == 1) return "1 - 2 años";
    if (experienceValue == 2) return "2 - 4 años";
    if (experienceValue == 3) return "4 - 6 años";
    return "> 6 años";
  }

  void addInstrument() {
    if (selectedInstrument == null || selectedLearningMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Selecciona instrumento y método de aprendizaje."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      addedInstruments.add({
        "name": selectedInstrument!,
        "experience": getExperienceLabel(),
        "learningMethod": selectedLearningMethod!,
      });

      selectedInstrument = null;
      selectedLearningMethod = null;
      experienceValue = 0;
    });
  }

  void removeInstrument(int index) {
    setState(() {
      addedInstruments.removeAt(index);
    });
  }

  void goNext() {
    if (addedInstruments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Añade al menos un instrumento."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    OnboardingData.instruments = addedInstruments;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const OnboardingGenresScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Instrumentos"),
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
                      "Paso 2 de 3",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "¿Qué instrumentos tocas?",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Añade todos los instrumentos que te representen como músico.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _DropdownField(
                      label: "Instrumento",
                      value: selectedInstrument,
                      hint: "Selecciona un instrumento",
                      items: instruments,
                      onChanged: (value) {
                        setState(() {
                          selectedInstrument = value;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Experiencia con el instrumento",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Slider(
                            value: experienceValue,
                            min: 0,
                            max: 4,
                            divisions: 4,
                            activeColor: Colors.orange,
                            inactiveColor: Colors.white24,
                            label: getExperienceLabel(),
                            onChanged: (value) {
                              setState(() {
                                experienceValue = value;
                              });
                            },
                          ),
                          Text(
                            getExperienceLabel(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _DropdownField(
                      label: "¿Dónde has aprendido?",
                      value: selectedLearningMethod,
                      hint: "Selecciona una opción",
                      items: learningMethods,
                      onChanged: (value) {
                        setState(() {
                          selectedLearningMethod = value;
                        });
                      },
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: addInstrument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Agregar instrumento",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    if (addedInstruments.isNotEmpty) ...[
                      const Text(
                        "Instrumentos añadidos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 14),

                      ...addedInstruments.asMap().entries.map(
                            (entry) => _AddedInstrumentCard(
                          instrument: entry.value,
                          onDelete: () => removeInstrument(entry.key),
                        ),
                      ),
                    ],

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
                          "Siguiente paso",
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

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final List<String> items;
  final Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
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

        DropdownButtonFormField<String>(
          value: value,
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
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white38),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _AddedInstrumentCard extends StatelessWidget {
  final Map<String, String> instrument;
  final VoidCallback onDelete;

  const _AddedInstrumentCard({
    required this.instrument,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final instrumentName = instrument["name"] ?? "Instrumento";
    final experience = instrument["experience"] ?? "";
    final learningMethod = instrument["learningMethod"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.music_note,
            color: Colors.orange,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instrumentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "$experience · $learningMethod",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.close,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}