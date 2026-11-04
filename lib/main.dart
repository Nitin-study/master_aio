import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'questions.dart';
import 'maths_gen.dart';
import 'progress.dart';
import 'loader.dart';
import 'notes.dart';
import 'config.dart';
import 'pro.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadExtra();
  await Pro.load();
  await AppConfig.load();
  runApp(const MasterAIO());
}

const Color okColor = Color(0x594CAF50);
const Color badColor = Color(0x59F44336);

Widget qaTile(Question q, {int? mine, bool showMine = false}) {
  final e = explain[q.q];
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.q,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          if (showMine)
            Text(
                mine == null
                    ? 'Skip kiya'
                    : 'Aapka jawab: ${q.options[mine]}',
                style: const TextStyle(color: Colors.redAccent)),
          Text('Sahi jawab: ${q.options[q.answer]}',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.w600)),
          if (e != null) ...[
            const SizedBox(height: 6),
            Text('Hal: $e'),
          ],
        ],
      ),
    ),
  );
}

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
        home: AppConfig.mustUpdate ? const UpdateScreen() : const Home(),
      ),
    );
  }
}

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.system_update, size: 80),
              SizedBox(height: 16),
              Text('Naya version aa gaya hai',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Kripya ऐप update karein.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ HOME

class Home extends StatefulWidget {
  const Home({super.key});
  static const subjects = [
    'Maths', 'Reasoning', 'English', 'Hindi', 'General Science',
    'Geography', 'History & Polity', 'J&K GK', 'Current Affairs', 'Computer'
  ];
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void go(Widget w) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => w))
        .then((_) => setState(() {}));
  }

  void open(String s) {
    if (Pro.locked(s)) {
      go(const ProScreen());
      return;
    }
    final chapters = withGenerated(s);
    if (chapters == null || chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$s ke sawal jaldi aa rahe hain')),
      );
      return;
    }
    go(ChapterScreen(subject: s, chapters: chapters));
  }

  void daily() {
    final now = DateTime.now();
    final r = Random(now.year * 10000 + now.month * 100 + now.day);
    final pool = allQuestions()..shuffle(r);
    if (pool.isEmpty) return;
    go(QuizScreen(
        title: 'Daily Quiz',
        questions: pool.take(10).toList(),
        subject: 'Daily',
        daily: true));
  }

  Widget stats() {
    return FutureBuilder<List<int>>(
      future: Progress.load(),
      builder: (_, snap) {
        final d = snap.data ?? [0, 0, 0, 0];
        final acc = d[1] == 0 ? 0 : (d[0] * 100 ~/ d[1]);
        return Card(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('${d[2]}', 'Tests'),
                _stat('${d[1]}', 'Sawal'),
                _stat('$acc%', 'Sahi'),
                _stat('🔥 ${d[3]}', 'Streak'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stat(String v, String l) => Column(
        children: [
          Text(v,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(l, style: const TextStyle(fontSize: 12)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Master AIO  •  ${DateTime.now().year}'),
        actions: [
          IconButton(
              icon: Icon(Icons.workspace_premium,
                  color: Pro.active ? Colors.amber : null),
              onPressed: () => go(const ProScreen())),
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => go(const SearchScreen())),
          IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () => go(const BookmarksScreen())),
          IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () => go(const AnalyticsScreen())),
          IconButton(
            icon: Icon(dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeNotifier.value =
                dark ? ThemeMode.light : ThemeMode.dark,
          ),
        ],
      ),
      body: Column(
        children: [
          if (AppConfig.message.isNotEmpty)
            Card(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.campaign),
                title: Text(AppConfig.message),
              ),
            ),
          stats(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(12),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                for (final s in Home.subjects)
                  Card(
                    child: InkWell(
                      onTap: () => open(s),
                      child: Center(
                        child: Text(
                            Pro.locked(s) ? '🔒 $s' : s,
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.today),
                    label: const Text('Daily Quiz'),
                    onPressed: daily,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.timer),
                    label: const Text('Mock Test'),
                    onPressed: () => go(const MockSetup()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------- CHAPTERS

class ChapterScreen extends StatelessWidget {
  final String subject;
  final Map<String, List<Question>> chapters;
  const ChapterScreen(
      {super.key, required this.subject, required this.chapters});

  int _year(String n) => chapterYear['$subject|$n'] ?? 0;

  void go(BuildContext context, String title, List<Question> qs,
      [String? chapter]) {
    if (chapter != null && Pro.locked(subject, chapter)) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ProScreen()));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              QuizScreen(title: title, questions: qs, subject: subject)),
    );
  }

  Widget tile(BuildContext context, String n) => Card(
        child: ListTile(
          leading: Icon(
              Pro.locked(subject, n) ? Icons.lock : Icons.menu_book),
          title: Text(n),
          subtitle: Text('${chapters[n]!.length} sawal'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(context, n, chapters[n]!, n),
        ),
      );

  Widget head(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
        child: Text(t,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    final cur = DateTime.now().year;
    final names = chapters.keys.toList();
    final nowN = names.where((n) => _year(n) == cur).toList();
    final evergreen = names.where((n) => _year(n) == 0).toList();
    final oldN = names.where((n) => _year(n) != 0 && _year(n) < cur).toList();
    final hasYears = names.any((n) => _year(n) != 0);
    final usable = [
      for (final n in [...nowN, ...evergreen, ...oldN])
        if (!Pro.locked(subject, n)) n
    ];
    final all = [for (final n in usable) ...chapters[n]!];
    final hasNotes = studyNotes.containsKey(subject);
    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        actions: [
          if (hasNotes)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => NotesScreen(subject: subject))),
            ),
        ],
      ),
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
          if (nowN.isNotEmpty) ...[
            head('$cur - Naya Session'),
            for (final n in nowN) tile(context, n),
          ] else if (hasYears)
            Card(
              child: ListTile(
                leading: const Icon(Icons.hourglass_top),
                title: Text('$cur ke sawal jaldi aa rahe hain'),
              ),
            ),
          if (evergreen.isNotEmpty) ...[
            head('Practice'),
            for (final n in evergreen) tile(context, n),
          ],
          if (oldN.isNotEmpty) ...[
            head('Purane saal'),
            for (final n in oldN) tile(context, n),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history_edu),
                title: const Text('Revision Notes (purane saal)'),
                subtitle: const Text('Sawal aur sahi jawab ek jagah'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RevisionScreen(
                        subject: subject,
                        data: {
                          for (final n in oldN)
                            if (!Pro.locked(subject, n)) n: chapters[n]!
                        }),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NotesScreen extends StatelessWidget {
  final String subject;
  const NotesScreen({super.key, required this.subject});
  @override
  Widget build(BuildContext context) {
    final items = studyNotes[subject] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('$subject - Notes')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final n in items)
            Card(
              child: ExpansionTile(
                title: Text(n[0],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedAlignment: Alignment.centerLeft,
                children: [Text(n[1], style: const TextStyle(fontSize: 16))],
              ),
            ),
        ],
      ),
    );
  }
}

class RevisionScreen extends StatelessWidget {
  final String subject;
  final Map<String, List<Question>> data;
  const RevisionScreen({super.key, required this.subject, required this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$subject - Revision')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final e in data.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
              child: Text(e.key,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            for (final q in e.value) qaTile(q),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ QUIZ

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final String subject;
  final bool daily;
  const QuizScreen(
      {super.key,
      required this.title,
      required this.questions,
      this.subject = 'Mix',
      this.daily = false});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> qs;
  int index = 0;
  int score = 0;
  int? selected;
  bool finished = false;
  Set<String> marked = {};

  List<Question> _fresh() =>
      (widget.questions.map((q) => q.shuffled(Random())).toList()..shuffle());

  @override
  void initState() {
    super.initState();
    qs = _fresh();
    Progress.bookmarkKeys().then((s) {
      if (mounted) setState(() => marked = s);
    });
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
        Progress.add(score, qs.length,
            subject: widget.subject, title: widget.title);
        if (widget.daily) Progress.markDaily();
      } else {
        index++;
        selected = null;
      }
    });
  }

  void restart() {
    setState(() {
      qs = _fresh();
      index = 0;
      score = 0;
      selected = null;
      finished = false;
    });
  }

  Future<void> mark() async {
    final q = qs[index];
    final now = await Progress.toggleBookmark(q);
    if (!mounted) return;
    setState(() {
      final k = Progress.key(q);
      if (now) {
        marked.add(k);
      } else {
        marked.remove(k);
      }
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
    final isMarked = marked.contains(Progress.key(q));
    final e = explain[q.q];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: (index + 1) / qs.length),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Question ${index + 1} / ${qs.length}'),
              const Spacer(),
              IconButton(
                icon: Icon(isMarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: mark,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(q.q,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          for (int i = 0; i < q.options.length; i++)
            Card(
              color: tint(i),
              child: ListTile(title: Text(q.options[i]), onTap: () => pick(i)),
            ),
          if (selected != null && e != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Hal: $e'),
              ),
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

// ------------------------------------------------------------------ MOCK

class MockSetup extends StatefulWidget {
  const MockSetup({super.key});
  @override
  State<MockSetup> createState() => _MockSetupState();
}

class _MockSetupState extends State<MockSetup> {
  String? subject;
  int count = 25;

  void start() {
    final subs = subject == null ? Home.subjects : [subject!];
    final lists = <List<SQ>>[];
    for (final s in subs) {
      if (Pro.locked(s)) continue;
      final items = <SQ>[];
      withGenerated(s)?.forEach((chapter, l) {
        if (Pro.locked(s, chapter)) return;
        for (final q in l) {
          items.add(SQ(s, q));
        }
      });
      if (items.isNotEmpty) {
        items.shuffle();
        lists.add(items);
      }
    }
    if (lists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Is subject ke sawal abhi uplabdh nahi')),
      );
      return;
    }
    final out = <SQ>[];
    int i = 0;
    while (out.length < count && lists.any((l) => l.length > i)) {
      for (final l in lists) {
        if (l.length > i && out.length < count) out.add(l[i]);
      }
      i++;
    }
    out.shuffle();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => MockScreen(items: out)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Subject',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Sab (mix)'),
                selected: subject == null,
                onSelected: (_) => setState(() => subject = null),
              ),
              for (final s in Home.subjects)
                ChoiceChip(
                  label: Text(s),
                  selected: subject == s,
                  onSelected: (_) => setState(() => subject = s),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Kitne sawal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final n in [10, 25, 50])
                ChoiceChip(
                  label: Text('$n'),
                  selected: count == n,
                  onSelected: (_) => setState(() => count = n),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Time: $count minute (har sawal 1 minute)\nMarking: +1 sahi, -0.25 galat'),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Test shuru karo'),
            onPressed: start,
          ),
        ],
      ),
    );
  }
}

class MockScreen extends StatefulWidget {
  final List<SQ> items;
  const MockScreen({super.key, required this.items});
  @override
  State<MockScreen> createState() => _MockScreenState();
}

class _MockScreenState extends State<MockScreen> {
  late final List<Question> qs;
  late final List<String> subs;
  final Map<int, int> answers = {};
  int index = 0;
  int secondsLeft = 0;
  Timer? timer;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    qs = widget.items.map((e) => e.q.shuffled(Random())).toList();
    subs = widget.items.map((e) => e.subject).toList();
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
    if (finished) return;
    timer?.cancel();
    final per = <String, List<int>>{};
    answers.forEach((k, v) {
      final l = per.putIfAbsent(subs[k], () => [0, 0]);
      l[1]++;
      if (qs[k].answer == v) l[0]++;
    });
    if (per.isNotEmpty) Progress.addMulti(per, 'Mock Test');
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
            if (wrong + skipped > 0)
              OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ReviewScreen(qs: qs, answers: answers)),
                ),
                child: const Text('Galat / Skip sawal dekho'),
              ),
            const SizedBox(height: 8),
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Home par jao')),
          ],
        ),
      ),
    );
  }
}

class ReviewScreen extends StatelessWidget {
  final List<Question> qs;
  final Map<int, int> answers;
  const ReviewScreen({super.key, required this.qs, required this.answers});
  @override
  Widget build(BuildContext context) {
    final idx = [
      for (int i = 0; i < qs.length; i++)
        if (answers[i] != qs[i].answer) i
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Galat / Skip sawal')),
      body: idx.isEmpty
          ? const Center(child: Text('Sab sahi! Shabaash'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final i in idx)
                  qaTile(qs[i], mine: answers[i], showMine: true),
              ],
            ),
    );
  }
}

// ------------------------------------------------------------- ANALYTICS

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, List<int>> stats = {};
  List<List<String>> hist = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await Progress.subjectStats();
    final h = await Progress.history();
    if (!mounted) return;
    setState(() {
      stats = s;
      hist = h;
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final entries = stats.entries.where((e) => e.value[1] > 0).toList()
      ..sort((a, b) =>
          (a.value[0] / a.value[1]).compareTo(b.value[0] / b.value[1]));
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Subject-wise (kamzor pehle)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Abhi koi test nahi diya. Ek quiz khelo!'),
            ),
          for (final e in entries)
            Card(
              child: ListTile(
                title: Text(e.key),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(
                      value: e.value[0] / e.value[1]),
                ),
                trailing: Text(
                    '${(e.value[0] * 100 / e.value[1]).round()}%  (${e.value[0]}/${e.value[1]})'
                    '${(e.value[0] / e.value[1] < 0.5 && e.value[1] >= 5) ? '  ⚠' : ''}'),
              ),
            ),
          const SizedBox(height: 16),
          const Text('Pichhle tests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (hist.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Koi history nahi.'),
            ),
          for (final h in hist)
            Card(
              child: ListTile(
                title: Text(h[1]),
                subtitle: Text(_date(h[0])),
                trailing: Text('${h[2]} / ${h[3]}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  String _date(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }
}

// ------------------------------------------------------------- BOOKMARKS

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Question> items = [];
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await Progress.bookmarks();
    if (!mounted) return;
    setState(() {
      items = b;
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Koi bookmark nahi. Quiz mein sawal ke upar bookmark dabao.',
                        textAlign: TextAlign.center),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow),
                      label: Text('Practice karo (${items.length})'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                              title: 'Bookmarks',
                              questions: items,
                              subject: 'Bookmarks'),
                        ),
                      ),
                    ),
                    for (final q in items) ...[
                      qaTile(q),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Hatao'),
                          onPressed: () async {
                            await Progress.toggleBookmark(q);
                            _load();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

// ---------------------------------------------------------------- SEARCH

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final List<SQ> all = allSQ();
  String text = '';

  @override
  Widget build(BuildContext context) {
    final t = text.trim().toLowerCase();
    final results = t.length < 2
        ? <SQ>[]
        : all.where((e) => e.q.q.toLowerCase().contains(t)).take(50).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Sawal ka koi shabd likho',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => text = v),
          ),
          const SizedBox(height: 8),
          if (t.length >= 2 && results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Kuch nahi mila.'),
            ),
          for (final r in results) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(r.subject, style: const TextStyle(fontSize: 12)),
            ),
            qaTile(r.q),
          ],
        ],
      ),
    );
  }
}
