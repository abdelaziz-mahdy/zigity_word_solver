// lib/services/wordle_service.dart
import 'text_loader/text_loader.dart';

class WordleService {
  Set<String> _wordSet = {};
  final TextLoader textLoader;

  WordleService({required this.textLoader});

  Future<void> loadWords() async {
    try {
      _wordSet = await textLoader.loadWords();
    } catch (e) {
      throw Exception('Failed to load words: $e');
    }
  }

  List<String> findWordleWords({
    required int wordLength,
    Map<int, String>? knownPositions, // Position -> Letter (green)
    List<String>? containsLetters, // Letters in word but wrong position (yellow)
    Map<String, List<int>>? wrongPositions, // Letter -> positions where it's NOT
    List<String>? excludedLetters, // Letters not in word (gray)
  }) {
    if (wordLength <= 0) return [];

    List<String> foundWords = _wordSet.where((word) {
      // Filter by word length
      if (word.length != wordLength) return false;

      // Check known positions (green letters)
      if (knownPositions != null) {
        for (var entry in knownPositions.entries) {
          int position = entry.key;
          String letter = entry.value.toLowerCase();

          if (position >= word.length) continue;
          if (word[position].toLowerCase() != letter) return false;
        }
      }

      // Check contains letters (yellow letters)
      if (containsLetters != null) {
        for (var letter in containsLetters) {
          if (!word.toLowerCase().contains(letter.toLowerCase())) {
            return false;
          }
        }
      }

      // Check wrong positions (yellow letters at specific positions)
      if (wrongPositions != null) {
        for (var entry in wrongPositions.entries) {
          String letter = entry.key.toLowerCase();
          List<int> positions = entry.value;

          // The word must contain this letter
          if (!word.toLowerCase().contains(letter)) return false;

          // But not at these specific positions
          for (var position in positions) {
            if (position < word.length &&
                word[position].toLowerCase() == letter) {
              return false;
            }
          }
        }
      }

      // Check excluded letters (gray letters)
      if (excludedLetters != null) {
        for (var letter in excludedLetters) {
          if (word.toLowerCase().contains(letter.toLowerCase())) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    // Sort by word frequency/commonality (for now, just alphabetically)
    foundWords.sort();

    // Limit results to prevent overwhelming UI
    if (foundWords.length > 100) {
      foundWords = foundWords.sublist(0, 100);
    }

    return foundWords;
  }

  /// Finds exploratory words that maximize letter elimination.
  /// These words test as many untested letters as possible.
  List<({String word, int score, int newLetters})> findExploratoryWords({
    required int wordLength,
    required Set<String> testedLetters,
    int limit = 20,
  }) {
    if (wordLength <= 0) return [];

    final List<({String word, int score, int newLetters})> scoredWords = [];

    for (final word in _wordSet) {
      if (word.length != wordLength) continue;

      final score = _scoreExploratoryWord(word, testedLetters);
      if (score.untestedCount > 0) {
        scoredWords.add((
          word: word,
          score: score.totalScore,
          newLetters: score.untestedCount,
        ));
      }
    }

    // Sort by score descending
    scoredWords.sort((a, b) => b.score.compareTo(a.score));

    // Return top N results
    if (scoredWords.length > limit) {
      return scoredWords.sublist(0, limit);
    }

    return scoredWords;
  }

  /// Scores a word for exploratory value.
  /// Higher scores mean more untested letters.
  ({int untestedCount, int totalScore}) _scoreExploratoryWord(
    String word,
    Set<String> testedLetters,
  ) {
    final letters = word.toLowerCase().split('');
    final uniqueLetters = letters.toSet();

    // Count untested unique letters
    final untestedCount =
        uniqueLetters.where((l) => !testedLetters.contains(l)).length;

    // Bonus: prefer words with all unique letters (no repeats)
    final uniqueBonus = (uniqueLetters.length == word.length) ? 1 : 0;

    final totalScore = untestedCount * 10 + uniqueBonus;

    return (untestedCount: untestedCount, totalScore: totalScore);
  }
}
