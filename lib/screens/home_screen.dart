import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        foregroundColor: Colors.black,
        title: const Text("VOCABULARY"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _buildActionCards(context),
      ),
    );
  }

  List<Widget> _buildActionCards(BuildContext context) {
    final actions = [
      {
        'title': 'Add New Words',
        'icon': Icons.add_circle,
        'route': '/add',
        'color': Colors.blue,
        'description': 'Build your vocabulary'
      },
      {
        'title': 'Take Quiz',
        'icon': Icons.quiz,
        'route': '/quiz',
        'color': Colors.green,
        'description': 'Test your knowledge'
      },
      {
        'title': 'Word List',
        'icon': Icons.list_alt,
        'route': '/list',
        'color': Colors.orange,
        'description': 'Review all words'
      },
    ];

    return actions.map((action) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, action['route'] as String),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action['icon'] as IconData,
                    color: action['color'] as Color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action['description'] as String,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    )).toList();
  }
}