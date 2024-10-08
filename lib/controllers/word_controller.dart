// lib/controllers/word_controller.dart
import 'package:flutter/material.dart';
import 'package:zigity_word_solver/services/text_loader/asset_text_loader.dart';
import 'package:zigity_word_solver/services/word_service.dart';

class WordController extends ChangeNotifier {
  final WordService _wordService =
      WordService(textLoader: AssetTextLoader(path: "assets/popular.txt"));
//  //   // const url =
  //   //     'https://raw.githubusercontent.com/dwyl/english-words/master/words.txt';
  //   const url =
  //       "https://raw.githubusercontent.com/dolph/dictionary/master/popular.txt";
  final List<String> _mandatoryLetters = [];
  final List<String> _availableLetters = [];
  List<String> _foundWords = [];
  bool _loading = false;
  String _errorMessage = '';

  List<String> get mandatoryLetters => _mandatoryLetters;
  List<String> get availableLetters => _availableLetters;
  List<String> get foundWords => _foundWords;
  bool get loading => _loading;
  bool dataLoaded = false;
  String get errorMessage => _errorMessage;

  Future<void> loadWords() async {
    _loading = true;
    dataLoaded = false;
    _errorMessage = '';
    notifyListeners();

    try {
      await _wordService.loadWords();
      dataLoaded = true;
    } catch (e) {
      _errorMessage = 'Failed to load words: ${e.toString()}';
      dataLoaded = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
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
      _mandatoryLetters,
      _availableLetters,
      freeLetters,
    );

    if (_foundWords.isEmpty) {
      _errorMessage = 'No valid words found.';
    } else {
      _errorMessage = '';
    }

    notifyListeners();
  }
}
