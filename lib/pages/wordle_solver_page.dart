// lib/pages/wordle_solver_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zigity_word_solver/controllers/wordle_controller.dart';

class WordleSolverPage extends StatefulWidget {
  const WordleSolverPage({super.key});

  @override
  State<WordleSolverPage> createState() => _WordleSolverPageState();
}

class _WordleSolverPageState extends State<WordleSolverPage> {
  late final WordleController wordleController;
  final List<TextEditingController> positionControllers = [];
  final TextEditingController containsLetterController =
      TextEditingController();
  final TextEditingController excludedLetterController =
      TextEditingController();
  final TextEditingController wordLengthController =
      TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    wordleController = Provider.of<WordleController>(context, listen: false);
    _initializePositionControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wordleController.loadWords();
    });
  }

  void _initializePositionControllers() {
    final currentLength = positionControllers.length;
    final targetLength = wordleController.wordLength;

    if (currentLength > targetLength) {
      // Remove extra controllers
      for (int i = currentLength - 1; i >= targetLength; i--) {
        positionControllers[i].dispose();
        positionControllers.removeAt(i);
      }
    } else if (currentLength < targetLength) {
      // Add new controllers
      for (int i = currentLength; i < targetLength; i++) {
        final existingValue = wordleController.knownPositions[i] ?? '';
        positionControllers.add(TextEditingController(text: existingValue));
      }
    }

    // Sync existing controllers with known positions
    for (int i = 0; i < targetLength && i < currentLength; i++) {
      final knownValue = wordleController.knownPositions[i] ?? '';
      if (positionControllers[i].text != knownValue) {
        positionControllers[i].text = knownValue;
      }
    }
  }

  void _updateWordLength() {
    final newLength = int.tryParse(wordLengthController.text);
    if (newLength == null || newLength <= 0 || newLength > 15) {
      return;
    }

    if (newLength == wordleController.wordLength) {
      return; // No change
    }

    wordleController.setWordLength(newLength);
    _initializePositionControllers();
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in positionControllers) {
      controller.dispose();
    }
    containsLetterController.dispose();
    excludedLetterController.dispose();
    wordLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordleController>(
      builder: (context, controller, child) {
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.errorMessage.isNotEmpty &&
            !controller.dataLoaded) {
          return Center(child: Text(controller.errorMessage));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word Length Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: wordLengthController,
                      decoration: const InputDecoration(
                        labelText: 'Word Length',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _updateWordLength,
                    child: const Text('Update'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Known Positions (Green Letters)
              const Text(
                'Known Positions (Green)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(
                  controller.wordLength,
                  (index) => SizedBox(
                    width: 50,
                    child: TextField(
                      controller: positionControllers[index],
                      decoration: InputDecoration(
                        labelText: '${index + 1}',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: positionControllers[index].text.isNotEmpty
                            ? Colors.green.withValues(alpha: 0.2)
                            : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                      ],
                      onChanged: (value) {
                        controller.setKnownPosition(index, value);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Contains Letters (Yellow)
              const Text(
                'Contains Letters (Yellow)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: containsLetterController,
                decoration: const InputDecoration(
                  labelText: 'Enter a letter that is in the word',
                  border: OutlineInputBorder(),
                ),
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
                onChanged: (value) {
                  if (value.length == 1) {
                    controller.addContainsLetter(value);
                    containsLetterController.clear();
                  }
                },
              ),
              const SizedBox(height: 10),
              ...controller.containsLetters.map((letter) {
                final wrongPositions = controller.wrongPositions[letter] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(letter.toUpperCase()),
                          backgroundColor: Colors.yellow.shade200,
                          onDeleted: () => controller.removeContainsLetter(letter),
                        ),
                        const SizedBox(width: 8),
                        const Text('Not at positions:'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: List.generate(
                        controller.wordLength,
                        (index) {
                          final isSelected = wrongPositions.contains(index);
                          return FilterChip(
                            label: Text('${index + 1}'),
                            selected: isSelected,
                            selectedColor: Colors.red.shade200,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setWrongPosition(letter, index);
                              } else {
                                controller.removeWrongPosition(letter, index);
                              }
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              const SizedBox(height: 10),

              // Excluded Letters (Gray)
              const Text(
                'Excluded Letters (Gray)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: excludedLetterController,
                decoration: const InputDecoration(
                  labelText: 'Enter a letter NOT in the word',
                  border: OutlineInputBorder(),
                ),
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
                onChanged: (value) {
                  if (value.length == 1) {
                    controller.addExcludedLetter(value);
                    excludedLetterController.clear();
                  }
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: controller.excludedLetters.map((letter) {
                  return Chip(
                    label: Text(letter.toUpperCase()),
                    backgroundColor: Colors.grey.shade400,
                    onDeleted: () => controller.removeExcludedLetter(letter),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.findWords,
                      child: const Text('Find Words'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearAll();
                        for (var ctrl in positionControllers) {
                          ctrl.clear();
                        }
                        setState(() {});
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Results
              if (controller.foundWords.isNotEmpty) ...[
                Text(
                  'Found ${controller.foundWords.length} words:',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: controller.foundWords.map((word) {
                    return Chip(
                      label: Text(word),
                      backgroundColor: Colors.blue.shade100,
                    );
                  }).toList(),
                ),
              ] else if (controller.errorMessage.isNotEmpty)
                Text(
                  controller.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }
}
