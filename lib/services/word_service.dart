// lib/services/word_service.dart
import 'package:http/http.dart' as http;

class WordService {
  Set<String> _wordSet = {};

  Future<void> loadWords() async {
    final url = 'https://raw.githubusercontent.com/dwyl/english-words/master/words.txt';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final words = response.body.split('\n');
        _wordSet = words.map((word) => word.trim().toLowerCase()).toSet();
      }
    } catch (e) {
      throw Exception('Failed to load words: $e');
    }
  }

  List<String> findWords(List<String> mandatoryLetters, List<String> availableLetters, int freeLetters) {
    String inputLetters = availableLetters.join('').toLowerCase();
    if (mandatoryLetters.isEmpty && inputLetters.isEmpty) return [];

    List<String> foundWords = _wordSet.where((word) => _canFormWord(
        word, mandatoryLetters.join(''), inputLetters, freeLetters)).toList();

    foundWords.sort((a, b) => _countUsedLetters(
        b, mandatoryLetters.join('') + inputLetters).compareTo(
        _countUsedLetters(a, mandatoryLetters.join('') + inputLetters)));

    if (foundWords.length > 5) {
      foundWords = foundWords.sublist(0, 5); // Limit to top 5 words
    }

    return foundWords;
  }

  bool _canFormWord(String word, String mandatoryLetters, String inputLetters, int freeLetters) {
    for (var letter in mandatoryLetters.split('')) {
      if (!word.contains(letter)) return false;
    }

    Map<String, int> letterCount = {};
    for (var letter in inputLetters.split('')) {
      letterCount[letter] = (letterCount[letter] ?? 0) + 1;
    }

    int neededFreeLetters = 0;

    for (var letter in word.split('')) {
      if (mandatoryLetters.contains(letter)) {
        continue;
      }

      if (letterCount.containsKey(letter) && letterCount[letter]! > 0) {
        letterCount[letter] = letterCount[letter]! - 1;
      } else {
        neededFreeLetters++;
      }
    }

    return neededFreeLetters <= freeLetters;
  }

  int _countUsedLetters(String word, String allLetters) {
    int count = 0;
    Set<String> usedLetters = {};
    for (var letter in word.split('')) {
      if (allLetters.contains(letter) && !usedLetters.contains(letter)) {
        count += word.split(letter).length - 1;
        usedLetters.add(letter);
      }
    }
    return count;
  }
}
