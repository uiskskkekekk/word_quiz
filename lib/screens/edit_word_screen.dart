import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/word.dart';

class EditWordScreen extends StatefulWidget {
  final Word word;

  EditWordScreen({required this.word});

  @override
  _EditWordScreenState createState() => _EditWordScreenState();
}

class _EditWordScreenState extends State<EditWordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _englishController;
  late TextEditingController _chineseController;
  late TextEditingController _categoryController;

  @override
  void initState() {
    super.initState();
    _englishController = TextEditingController(text: widget.word.english);
    _chineseController = TextEditingController(text: widget.word.chinese);
    _categoryController = TextEditingController(text: widget.word.category ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit word'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _englishController,
                decoration: InputDecoration(
                  labelText: 'English words',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                  return 'Please enter English words';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _chineseController,
                decoration: InputDecoration(
                  labelText: 'Chinese meaning',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Chinese meaning';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedWord = widget.word.copyWith(
                      english: _englishController.text,
                      chinese: _chineseController.text,
                      category: _categoryController.text.isEmpty
                          ? null
                          : _categoryController.text,
                    );
                    await DatabaseService.instance.update(updatedWord);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update successful！')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _englishController.dispose();
    _chineseController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
