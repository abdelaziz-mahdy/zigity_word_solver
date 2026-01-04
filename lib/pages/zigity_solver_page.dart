// lib/pages/zigity_solver_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zigity_word_solver/controllers/word_controller.dart';

class ZigitySolverPage extends StatefulWidget {
  const ZigitySolverPage({super.key});

  @override
  State<ZigitySolverPage> createState() => _ZigitySolverPageState();
}

class _ZigitySolverPageState extends State<ZigitySolverPage> {
  late final WordController wordController;
  final TextEditingController mandatoryLetterController =
      TextEditingController();
  final TextEditingController availableLetterController =
      TextEditingController();
  final TextEditingController freeLettersController = TextEditingController();

  @override
  void initState() {
    super.initState();
    wordController = Provider.of<WordController>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wordController.loadWords();
    });
  }

  @override
  void dispose() {
    mandatoryLetterController.dispose();
    availableLetterController.dispose();
    freeLettersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordController>(
      builder: (context, wordController, child) {
        if (wordController.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (wordController.errorMessage.isNotEmpty &&
            !wordController.dataLoaded) {
          return Center(child: Text(wordController.errorMessage));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: mandatoryLetterController,
                decoration: const InputDecoration(
                  labelText: 'Enter a mandatory letter',
                  border: OutlineInputBorder(),
                ),
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
                onChanged: (value) {
                  if (value.isEmpty &&
                      wordController.mandatoryLetters.isNotEmpty) {
                    wordController
                        .removeMandatoryLetter(wordController.mandatoryLetters.first);
                  }
                  if (value.length == 1) {
                    wordController.addMandatoryLetter(value);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: availableLetterController,
                decoration: const InputDecoration(
                  labelText: 'Enter available letters',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    wordController.addAvailableLetter(value);
                    availableLetterController.clear();
                  }
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  ...wordController.mandatoryLetters.map((letter) => Chip(
                        label: Text(letter),
                        backgroundColor: Colors.transparent,
                        shape: const StadiumBorder(
                          side: BorderSide(color: Colors.redAccent),
                        ),
                        onDeleted: () =>
                            wordController.removeMandatoryLetter(letter),
                      )),
                  ...wordController.availableLetters.map((letter) => Chip(
                        label: Text(letter),
                        backgroundColor: Colors.transparent,
                        shape: const StadiumBorder(
                          side: BorderSide(color: Colors.blueAccent),
                        ),
                        onDeleted: () =>
                            wordController.removeAvailableLetter(letter),
                      )),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: freeLettersController,
                decoration: const InputDecoration(
                  labelText: 'Enter number of free letters',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  wordController.findWords(
                      int.tryParse(freeLettersController.text) ?? 0);
                },
                child: const Text('Find Words'),
              ),
              const SizedBox(height: 20),
              if (wordController.foundWords.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: wordController.foundWords.map((word) {
                    return Chip(
                      label: Text(word),
                      backgroundColor: Colors.transparent,
                      shape: const StadiumBorder(
                        side: BorderSide(color: Colors.blueAccent),
                      ),
                    );
                  }).toList(),
                )
              else if (wordController.errorMessage.isNotEmpty)
                Text(wordController.errorMessage),
            ],
          ),
        );
      },
    );
  }
}
