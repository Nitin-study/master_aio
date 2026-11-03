import 'dart:async';
import 'package:flutter/material.dart';
import 'questions.dart';
import 'maths_gen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() => runApp(const MasterAIO());

const Color okColor = Color(0x594CAF50);
const Color badColor = Color(0x59F44336);

class MasterAIO extends StatelessWidget {
  const MasterAIO({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => MaterialApp(
        title: 'Master AIO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true),
        themeMode: mode,
        home: const Home(),
      ),
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
   final chapters = withGenerated(s);
    if (chapters == null || chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$s ke sawal jaldi aa rahe hain')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ChapterScreen(subject: s, chapters: chapters)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master AIO'),
        actions: [
          IconButton(
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeNotifier.value =
                dark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.timer),
                label: const Text('Full Mock Test (Timer)'),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const MockScreen())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterScreen extends StatelessWidget {
  final String subject;
  final Map<String, List<Question>> chapters;
  const ChapterScreen(
      {super.key, required this.subject, required this.chapters});

  void go(BuildContext context, String title, List<Question> qs) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(title: title, questions: qs)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final names = chapters.keys.toList();
    final all = chapters.values.expand((l) => l).toList();
    return Scaffold(
      appBar: AppBar(title: Text(subject)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.shuffle),
              title: const Text('Saare chapters (mix)'),
              subtitle: Text('${all.length} sawal'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => go(context, '$subject - Mix', all),
            ),
          ),
          for (final n in names)
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: Text(n),
                subtitle: Text('${chapters[n]!.length} sawal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => go(context, n, chapters[n]!),
              ),
            ),
        ],
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  const QuizScreen({super.key, required this.title, required this.questions});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<Question> qs;
  int index = 0;
  int score = 0;
  int? selected;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    qs = List<Question>.from(widget.questions)..shuffle();
  }

  void pick(int i) {
    if (selected != null) return;
    setState(() {
      selected = i;
      if (i == qs[index].answer) score++;
    });
  }

  void next() {
    setState(() {
      if (index + 1 >= qs.length) {
        finished = true;
      } else {
        index++;
        selected = null;
      }
    });
  }

  void restart() {
    setState(() {
      qs.shuffle();
      index = 0;
      score = 0;
      selected = null;
      finished = false;
    });
  }

  Color? tint(int i) {
    if (selected == null) return null;
    if (i == qs[index].answer) return okColor;
    if (i == selected) return badColor;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: finished ? result() : question(),
    );
  }

  Widget result() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Score: $score / ${qs.length}',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: restart, child: const Text('Dobara try kar')),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Wapas jao')),
          ],
        ),
      ),
    );
  }

  Widget question() {
    final q = qs[index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: (index + 1) / qs.length),
          const SizedBox(height: 12),
          Text('Question ${index + 1} / ${qs.length}'),
          const SizedBox(height: 12),
          Text(q.q,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          for (int i = 0; i < q.options.length; i++)
            Card(
              color: tint(i),
              child: ListTile(title: Text(q.options[i]), onTap: () => pick(i)),
            ),
          const SizedBox(height: 12),
          if (selected != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: next,
                child: Text(index + 1 == qs.length ? 'Result dekho' : 'Next'),
              ),
            ),
        ],
      ),
    );
  }
}

class MockScreen extends StatefulWidget {
  const MockScreen({super.key});
  @override
  State<MockScreen> createState() => _MockScreenState();
}

class _MockScreenState extends State<MockScreen> {
  late final List<Question> qs;
  final Map<int, int> answers = {};
  int index = 0;
  int secondsLeft = 0;
  Timer? timer;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    final all =
        bank.values.expand((m) => m.values).expand((l) => l).toList()..shuffle();
    qs = all.take(25).toList();
    secondsLeft = qs.length * 60;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) {
        secondsLeft = 0;
        submit();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void submit() {
    timer?.cancel();
    setState(() => finished = true);
  }

  String get timeText {
    final m = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Test'),
        actions: finished
            ? null
            : [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(timeText,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
      ),
      body: finished ? result() : body(),
    );
  }

  Widget body() {
    final q = qs[index];
    final last = index == qs.length - 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: (index + 1) / qs.length),
          const SizedBox(height: 12),
          Text('Question ${index + 1} / ${qs.length}   (+1 / -0.25)'),
          const SizedBox(height: 12),
          Text(q.q,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          for (int i = 0; i < q.options.length; i++)
            Card(
              color: answers[index] == i
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: ListTile(
                title: Text(q.options[i]),
                onTap: () => setState(() => answers[index] = i),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (index > 0)
                OutlinedButton(
                    onPressed: () => setState(() => index--),
                    child: const Text('Previous')),
              const Spacer(),
              if (!last)
                FilledButton(
                    onPressed: () => setState(() => index++),
                    child: const Text('Next')),
              if (last)
                FilledButton(onPressed: submit, child: const Text('Submit')),
            ],
          ),
        ],
      ),
    );
  }

  Widget result() {
    int correct = 0, wrong = 0;
    answers.forEach((k, v) {
      if (qs[k].answer == v) {
        correct++;
      } else {
        wrong++;
      }
    });
    final skipped = qs.length - answers.length;
    final marks = correct - wrong * 0.25;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Marks: ${marks.toStringAsFixed(2)} / ${qs.length}',
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Sahi: $correct    Galat: $wrong    Skip: $skipped',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Home par jao')),
          ],
        ),
      ),
    );
  }
}
