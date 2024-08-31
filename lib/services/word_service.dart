// lib/services/word_service.dart
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WordService {
  Set<String> _wordSet = {};

  // Future<void> loadWords() async {
  //   // const url =
  //   //     'https://raw.githubusercontent.com/dwyl/english-words/master/words.txt';
  //   const url =
  //       "https://raw.githubusercontent.com/dolph/dictionary/master/popular.txt";
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final words = response.body.split('\n');
  //       _wordSet = words.map((word) => word.trim().toLowerCase()).toSet();
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to load words: $e');
  //   }
  // }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> loadWords() async {
    try {
      final words = (await getFileData("assets/popular.txt")).split('\n');
      _wordSet = words.map((word) => word.trim().toLowerCase()).toSet();
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

    if (foundWords.length > 5) {
      foundWords = foundWords.sublist(0, 5); // Limit to top 5 words
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
    Map<String, int> letterCount = {mandatoryLetters.firstOrNull ?? "": 1};
    for (var letter in availableLetters) {
      letterCount[letter] = (letterCount[letter] ?? 0) + 1;
    }

    int neededFreeLetters = 0;

    for (var letter in word.split('')) {
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

  // int _countUsedLetters(String word, List<String> mandatoryLetters,
  //     List<String> availableLetters) {
  //   int count = 0;
  //   Set<String> usedLetters = {};

  //   List<String> allLetters = [...mandatoryLetters, ...availableLetters];

  //   for (var letter in word.split('')) {
  //     if (allLetters.contains(letter) && !usedLetters.contains(letter)) {
  //       count += word.split(letter).length - 1;
  //       usedLetters.add(letter);
  //     }
  //   }
  //   return count;
  // }
}
