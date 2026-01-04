// lib/controllers/wordle_controller.dart
import 'package:flutter/material.dart';
import 'package:zigity_word_solver/services/text_loader/asset_text_loader.dart';
import 'package:zigity_word_solver/services/wordle_service.dart';

class WordleController extends ChangeNotifier {
  final WordleService _wordleService =
      WordleService(textLoader: AssetTextLoader(path: "assets/wordlist.txt"));

  int _wordLength = 5;
  final Map<int, String> _knownPositions = {}; // Position -> Letter (green)
  final List<String> _containsLetters = []; // Yellow letters
  final Map<String, List<int>> _wrongPositions = {}; // Letter -> wrong positions
  final List<String> _excludedLetters = []; // Gray letters
  List<String> _foundWords = [];
  bool _loading = false;
  String _errorMessage = '';
  bool dataLoaded = false;

  int get wordLength => _wordLength;
  Map<int, String> get knownPositions => _knownPositions;
  List<String> get containsLetters => _containsLetters;
  Map<String, List<int>> get wrongPositions => _wrongPositions;
  List<String> get excludedLetters => _excludedLetters;
  List<String> get foundWords => _foundWords;
  bool get loading => _loading;
  String get errorMessage => _errorMessage;

  Future<void> loadWords() async {
    _loading = true;
    dataLoaded = false;
    _errorMessage = '';
    notifyListeners();

    try {
      await _wordleService.loadWords();
      dataLoaded = true;
    } catch (e) {
      _errorMessage = 'Failed to load words: ${e.toString()}';
      dataLoaded = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setWordLength(int length) {
    _wordLength = length;

    // Remove known positions that are beyond the new word length
    _knownPositions.removeWhere((position, _) => position >= length);

    // Remove wrong positions that are beyond the new word length
    for (var letter in _wrongPositions.keys) {
      _wrongPositions[letter]?.removeWhere((position) => position >= length);
    }

    notifyListeners();
  }

  void setKnownPosition(int position, String letter) {
    if (letter.isEmpty) {
      _knownPositions.remove(position);
    } else {
      _knownPositions[position] = letter.toLowerCase();
    }
    notifyListeners();
  }

  void addContainsLetter(String letter) {
    if (letter.isNotEmpty && !_containsLetters.contains(letter.toLowerCase())) {
      _containsLetters.add(letter.toLowerCase());
      notifyListeners();
    }
  }

  void removeContainsLetter(String letter) {
    _containsLetters.remove(letter.toLowerCase());
    _wrongPositions.remove(letter.toLowerCase());
    notifyListeners();
  }

  void setWrongPosition(String letter, int position) {
    letter = letter.toLowerCase();
    if (!_wrongPositions.containsKey(letter)) {
      _wrongPositions[letter] = [];
    }
    if (!_wrongPositions[letter]!.contains(position)) {
      _wrongPositions[letter]!.add(position);
    }
    notifyListeners();
  }

  void removeWrongPosition(String letter, int position) {
    letter = letter.toLowerCase();
    _wrongPositions[letter]?.remove(position);
    if (_wrongPositions[letter]?.isEmpty ?? false) {
      _wrongPositions.remove(letter);
    }
    notifyListeners();
  }

  void addExcludedLetter(String letter) {
    if (letter.isNotEmpty && !_excludedLetters.contains(letter.toLowerCase())) {
      _excludedLetters.add(letter.toLowerCase());
      notifyListeners();
    }
  }

  void removeExcludedLetter(String letter) {
    _excludedLetters.remove(letter.toLowerCase());
    notifyListeners();
  }

  void findWords() {
    _foundWords = _wordleService.findWordleWords(
      wordLength: _wordLength,
      knownPositions: _knownPositions.isEmpty ? null : _knownPositions,
      containsLetters: _containsLetters.isEmpty ? null : _containsLetters,
      wrongPositions: _wrongPositions.isEmpty ? null : _wrongPositions,
      excludedLetters: _excludedLetters.isEmpty ? null : _excludedLetters,
    );

    if (_foundWords.isEmpty) {
      _errorMessage = 'No valid words found.';
    } else {
      _errorMessage = '';
    }

    notifyListeners();
  }

  void clearAll() {
    _knownPositions.clear();
    _containsLetters.clear();
    _wrongPositions.clear();
    _excludedLetters.clear();
    _foundWords.clear();
    _errorMessage = '';
    notifyListeners();
  }
}
