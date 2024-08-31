// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zigity_word_solver/controllers/word_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WordController(),
      child: const MaterialApp(
        title: 'Zigity Word Solver',
        themeMode: ThemeMode.system,
        home: MyHomePage(title: 'Zigity Word Solver'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Consumer<WordController>(
          builder: (context, wordController, child) {
            if (wordController.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (wordController.errorMessage.isNotEmpty &&
                !wordController.dataLoaded) {
              return Center(child: Text(wordController.errorMessage));
            } else {
              return Padding(
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
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z]')), // Allow only letters
                      ],
                      onChanged: (value) {
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
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z]')), // Allow only letters
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
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Allow only digits
                      ],
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
            }
          },
        ),
      ),
    );
  }
}
