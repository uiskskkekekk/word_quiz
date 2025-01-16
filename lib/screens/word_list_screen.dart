import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/word.dart';
import 'edit_word_screen.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> words = [];
  List<String> categories = [];
  String? selectedCategory;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadWords();
    _loadCategories();
  }

  Future<void> _loadWords() async {
    final loadedWords = selectedCategory == null
        ? await DatabaseService.instance.getAllWords()
        : await DatabaseService.instance.getWordsByCategory(selectedCategory!);

    setState(() {
      words = loadedWords.where((word) {
        final query = searchQuery.toLowerCase();
        return word.english.toLowerCase().contains(query) ||
            word.chinese.contains(query);
      }).toList();
    });
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await DatabaseService.instance.getAllCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  Future<void> _deleteWord(Word word) async {
    await DatabaseService.instance.delete(word.id!);
    _loadWords();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Word deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word List'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () async {
              final jsonStr = await DatabaseService.instance.exportToJson();
              // TODO: Implement actual file saving logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data exported successfully')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () {
              // TODO: Implement file picking and importing logic
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search word...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _loadWords();
                });
              },
            ),
          ),
          if (categories.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text('Select Category'),
                value: selectedCategory,
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All'),
                  ),
                  ...categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    _loadWords();
                  });
                },
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                return Dismissible(
                  key: Key(word.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteWord(word);
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(word.english),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(word.chinese),
                          if (word.category != null)
                            Text(
                              'Category: ${word.category}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            word.createTime.toString().split(' ')[0],
                            style: TextStyle(color: Colors.grey),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditWordScreen(word: word),
                                ),
                              );
                              _loadWords();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
