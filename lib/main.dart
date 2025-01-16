import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'screens/add_word_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/word_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Word Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/add': (context) => AddWordScreen(),
        '/quiz': (context) => QuizScreen(),
        '/list': (context) => WordListScreen(),
      },
    );
  }
}