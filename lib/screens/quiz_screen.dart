import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/word.dart';
import 'dart:math';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  List<Word> allWords = [];
  Word? currentWord;
  List<String> options = [];
  int score = 0;
  int totalQuestions = 0;
  bool questionAnswered = false;
  String? selectedAnswer;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadWords();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadWords() async {
    allWords = await DatabaseService.instance.getAllWords();
    if (allWords.length < 4) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Hint'),
          content: Text('Please add at least 4 words before starting the test'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              child: Text('confirm'),
            ),
          ],
        ),
      );
      return;
    }
    _nextQuestion();
  }

  void _nextQuestion() {
    if (allWords.isEmpty) return;

    setState(() {
      questionAnswered = false;
      selectedAnswer = null;
      currentWord = allWords[Random().nextInt(allWords.length)];
      options = _generateOptions();
    });

    _animationController.reset();
    _animationController.forward();
  }

  List<String> _generateOptions() {
    List<String> options = [currentWord!.chinese];
    List<Word> otherWords = List.from(allWords)
      ..remove(currentWord)
      ..shuffle();

    options.addAll(
      otherWords.take(3).map((word) => word.chinese),
    );

    options.shuffle();
    return options;
  }

  void _checkAnswer(String selected) {
    if (questionAnswered) return;
    selectedAnswer = selected;

    setState(() {
      questionAnswered = true;
      totalQuestions++;
      if (selected == currentWord!.chinese) {
        score++;
      }
    });

    // 更新統計資料
    DatabaseService.instance.updateQuizStats(
      currentWord!.id!,
      selected == currentWord!.chinese,
    );

    // 顯示結果對話框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          selected == currentWord!.chinese ? 'Correct!' : 'Wrong answer',
          style: TextStyle(
            color: selected == currentWord!.chinese ? Colors.green : Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('English：${currentWord!.english}'),
            SizedBox(height: 3),
            Text('Chinese：${currentWord!.chinese}'),
            SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: DatabaseService.instance.getWordStats(currentWord!.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final stats = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Statistics of this word：'),
                    SizedBox(height: 3),
                    Text('Correct Count：${stats['correct']}'),
                    SizedBox(height: 3),
                    Text('Total Attempts：${stats['attempts']}'),
                    SizedBox(height: 3),
                    Text('Accuracy：${(stats['accuracy'] * 100).toStringAsFixed(1)}%'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nextQuestion();
            },
            child: Text('Next'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        foregroundColor: Colors.black,
        title: const Text("QUIZ"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '$score / $totalQuestions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: currentWord == null
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        'Question ${totalQuestions + 1}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentWord!.english,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ...options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    color: questionAnswered
                        ? option == currentWord!.chinese
                        ? Colors.green[50]
                        : option == selectedAnswer
                        ? Colors.red[50]
                        : Colors.white
                        : Colors.white,
                    child: InkWell(
                      onTap: () => _checkAnswer(option),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Icon(
                              questionAnswered
                                  ? option == currentWord!.chinese
                                  ? Icons.check_circle
                                  : option == selectedAnswer
                                  ? Icons.cancel
                                  : Icons.radio_button_unchecked
                                  : Icons.radio_button_unchecked,
                              color: questionAnswered
                                  ? option == currentWord!.chinese
                                  ? Colors.green
                                  : option == selectedAnswer
                                  ? Colors.red
                                  : Colors.grey
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 18,
                                color: questionAnswered
                                    ? option == currentWord!.chinese
                                    ? Colors.green
                                    : option == selectedAnswer
                                    ? Colors.red
                                    : Colors.black
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
