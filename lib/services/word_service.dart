// lib/services/word_service.dart
import 'text_loader/text_loader.dart';

class WordService {
  Set<String> _wordSet = {};
  final TextLoader textLoader;

  WordService({required this.textLoader});

  Future<void> loadWords() async {
    try {
      _wordSet = await textLoader.loadWords();
    } catch (e) {
      throw Exception('Failed to load words: $e');
    }
  }

  List<String> findWords(List<String> mandatoryLetters,
      List<String> availableLetters, int freeLetters) {
    if (mandatoryLetters.isEmpty && availableLetters.isEmpty) return [];

    List<String> foundWords = _wordSet
        .where((word) =>
            _canFormWord(word, mandatoryLetters, availableLetters, freeLetters))
        .toList();

    foundWords.sort((b, a) => a.length.compareTo(b.length));

    if (foundWords.length > 10) {
      foundWords = foundWords.sublist(0, 10); // Limit to top 5 words
    }

    return foundWords;
  }

  bool _canFormWord(String word, List<String> mandatoryLetters,
      List<String> availableLetters, int freeLetters) {
    // Ensure the word contains all mandatory letters
    for (var letter in mandatoryLetters) {
      if (!word.contains(letter)) return false;
    }

    // Count the letters in the input available letters
    Map<String, int> letterCount = {};
    for (var letter in availableLetters) {
      letterCount[letter] = (letterCount[letter] ?? 0) + 1;
    }

    int neededFreeLetters = 0;

    for (var letter in word.split('')) {
      if (mandatoryLetters.contains(letter)) {
        // Mandatory letters are already counted, continue
        continue;
      }

      if (letterCount.containsKey(letter) && letterCount[letter]! > 0) {
        // Use an available letter if possible
        letterCount[letter] = letterCount[letter]! - 1;
      } else {
        // If no more available letters, count it as a needed free letter
        neededFreeLetters++;
      }
    }

    // Ensure the word can be formed with the available letters and free letters
    return neededFreeLetters <= freeLetters;
  }
}
