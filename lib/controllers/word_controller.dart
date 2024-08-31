// lib/controllers/word_controller.dart
import 'package:flutter/material.dart';
import 'package:zigity_word_solver/services/word_service.dart';

class WordController extends ChangeNotifier {
  final WordService _wordService = WordService();

  final List<String> _mandatoryLetters = [];
  final List<String> _availableLetters = [];
  List<String> _foundWords = [];
  bool _loading = false;

  List<String> get mandatoryLetters => _mandatoryLetters;
  List<String> get availableLetters => _availableLetters;
  List<String> get foundWords => _foundWords;
  bool get loading => _loading;

  Future<void> loadWords() async {
    _loading = true;
    notifyListeners();

    await _wordService.loadWords();

    _loading = false;
    notifyListeners();
  }

  void addMandatoryLetter(String letter) {
    if (letter.isNotEmpty) {
      _mandatoryLetters.add(letter);
      notifyListeners();
    }
  }

  void removeMandatoryLetter(String letter) {
    _mandatoryLetters.remove(letter);
    notifyListeners();
  }

  void addAvailableLetter(String letter) {
    if (letter.isNotEmpty) {
      _availableLetters.add(letter);
      notifyListeners();
    }
  }

  void removeAvailableLetter(String letter) {
    _availableLetters.remove(letter);
    notifyListeners();
  }

  void findWords(int freeLetters) {
    _foundWords = _wordService.findWords(
        _mandatoryLetters, _availableLetters, freeLetters);
    print("found words $_foundWords");
    notifyListeners();
  }
}
