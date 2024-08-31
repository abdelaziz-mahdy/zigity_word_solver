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
      child: MaterialApp(
        title: 'Zigity Word Solver',
        themeMode: ThemeMode.system, // Use system theme mode
        home: const MyHomePage(title: 'Zigity Word Solver'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final wordController = Provider.of<WordController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter mandatory letters (one at a time)',
                border: OutlineInputBorder(),
              ),
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Allow only letters
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  wordController.addMandatoryLetter(value);
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter available letters (one at a time)',
                border: OutlineInputBorder(),
              ),
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')), // Allow only letters
              ],
              onChanged: (value) {
                if (value.isNotEmpty) {
                  wordController.addAvailableLetter(value);
                }
              },
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ...wordController.mandatoryLetters.map((letter) => Chip(
                      label: Text(letter),
                      backgroundColor: Colors.redAccent,
                      onDeleted: () => wordController.removeMandatoryLetter(letter),
                    )),
                ...wordController.availableLetters.map((letter) => Chip(
                      label: Text(letter),
                      backgroundColor: Colors.blueAccent,
                      onDeleted: () => wordController.removeAvailableLetter(letter),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter number of free letters',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Trigger word search
                wordController.findWords(int.tryParse(freeLettersController.text) ?? 0);
              },
              child: const Text('Find Words'),
            ),
            const SizedBox(height: 20),
            wordController.loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: wordController.foundWords.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(wordController.foundWords[index]),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
