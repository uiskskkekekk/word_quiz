import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/word.dart';

class FileService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/word_backup.json');
  }

  static Future<void> exportWords(List<Word> words) async {
    final file = await _localFile;
    final data = json.encode(words.map((w) => w.toJson()).toList());
    await file.writeAsString(data);
  }

  static Future<List<Word>> importWords() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((json) => Word.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}