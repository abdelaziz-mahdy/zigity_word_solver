import 'package:flutter/services.dart';
import 'package:zigity_word_solver/services/text_loader/text_loader.dart';

class AssetTextLoader implements TextLoader {
  final String path;

  AssetTextLoader({required this.path});

  @override
  Future<Set<String>> loadWords() async {
    try {
      final wordData = await rootBundle.loadString(path);
      final words = wordData.split('\n');
      return words.map((word) => word.trim().toLowerCase()).toSet();
    } catch (e) {
      throw Exception('Failed to load from asset: $e');
    }
  }
}
