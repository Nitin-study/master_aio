import 'package:flutter/material.dart';

void main() => runApp(const MasterAIO());

class Question {
  final String q;
  final List<String> options;
  final int answer;
  const Question(this.q, this.options, this.answer);
}

const Map<String, List<Question>> bank = {
  'Maths': [
    Question('15% of 200 = ?', ['20', '30', '25', '35'], 1),
    Question('Square root of 144 = ?', ['11', '12', '14', '13'], 1),
    Question('Average of 10, 20, 30 = ?', ['15', '25', '20', '30'], 2),
    Question('Speed 60 km/h, distance in 3 hours = ?',
        ['120 km', '150 km', '180 km', '200 km'], 2),
    Question('LCM of 4 and 6 = ?', ['12', '24', '10', '8'], 0),
  ],
  'English': [
    Question('Synonym of "Happy"', ['Sad', 'Joyful', 'Angry', 'Tired'], 1),
    Question('Plural of "Child"', ['Childs', 'Childes', 'Children', 'Child'], 2),
    Question('Antonym of "Brave"', ['Strong', 'Coward', 'Bold', 'Hero'], 1),
  ],
  'J&K GK': [
    Question('Dal Lake is in which city?',
        ['Jammu', 'Srinagar', 'Leh', 'Anantnag'], 1),
    Question('Which river flows through Srinagar?',
        ['Chenab', 'Ravi', 'Jhelum', 'Beas'], 2),
  ],
};

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

  void open(BuildContext context, String s) {
    final qs = bank[s];
    if (qs == null || qs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$s ke sawal jaldi aa rahe hain')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => QuizScreen(subject: s, questions: qs)),
    );
  }

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
                onTap: () => open(context, s),
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

class QuizScreen extends StatefulWidget {
  final String subject;
  final List<Question> questions;
  const QuizScreen({super.key, required this.subject, required this.questions});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int index = 0;
  int score = 0;
  int? selected;
  bool finished = false;

  void pick(int i) {
    if (selected != null) return;
    setState(() {
      selected = i;
      if (i == widget.questions[index].answer) score++;
    });
  }

  void next() {
    setState(() {
      if (index + 1 >= widget.questions.length) {
        finished = true;
      } else {
        index++;
        selected = null;
      }
    });
  }

  void restart() {
    setState(() {
      index = 0;
      score = 0;
      selected = null;
      finished = false;
    });
  }

  Color? tint(int i) {
    if (selected == null) return null;
    if (i == widget.questions[index].answer) return Colors.green.shade100;
    if (i == selected) return Colors.red.shade100;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    return Scaffold(
      appBar: AppBar(title: Text(widget.subject)),
      body: finished ? result(total) : question(total),
    );
  }

  Widget result(int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Score: $score / $total',
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            FilledButton(onPressed: restart, child: const Text('Dobara try kar')),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Home par jao')),
          ],
        ),
      ),
    );
  }

  Widget question(int total) {
    final q = widget.questions[index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: (index + 1) / total),
          const SizedBox(height: 12),
          Text('Question ${index + 1} / $total'),
          const SizedBox(height: 12),
          Text(q.q,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          for (int i = 0; i < q.options.length; i++)
            Card(
              color: tint(i),
              child: ListTile(
                title: Text(q.options[i]),
                onTap: () => pick(i),
              ),
            ),
          const SizedBox(height: 12),
          if (selected != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: next,
                child: Text(index + 1 == total ? 'Result dekho' : 'Next'),
              ),
            ),
        ],
      ),
    );
  }
}
