import 'package:flutter/material.dart';

void main() => runApp(const MasterAIO());

class MasterAIO extends StatelessWidget {
  const MasterAIO({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master AIO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});
  static const subjects = [
    'Maths', 'Reasoning', 'English', 'Hindi', 'General Science',
    'Geography', 'History & Polity', 'J&K GK', 'Current Affairs', 'Computer'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master AIO')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          for (final s in subjects)
            Card(
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: Text(s,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
