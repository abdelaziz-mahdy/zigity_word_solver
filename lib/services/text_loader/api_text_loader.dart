// lib/services/text_loader.dart

import 'package:http/http.dart' as http;
import 'package:zigity_word_solver/services/text_loader/text_loader.dart';

class ApiTextLoader implements TextLoader {
  final String url;

  ApiTextLoader({required this.url});

  @override
  Future<Set<String>> loadWords() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final words = response.body.split('\n');
        return words.map((word) => word.trim().toLowerCase()).toSet();
      } else {
        throw Exception('Failed to load from API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load from API: $e');
    }
  }
}
