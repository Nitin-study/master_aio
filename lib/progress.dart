import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'questions.dart';

class Progress {
  static Future<void> add(int correct, int attempted,
      {String subject = 'Mix', String title = 'Quiz'}) {
    return addMulti({
      subject: [correct, attempted]
    }, title);
  }

  static Future<void> addMulti(
      Map<String, List<int>> per, String title) async {
    final p = await SharedPreferences.getInstance();
    int c = 0, a = 0;
    final raw = p.getString('subj');
    final m = raw == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(jsonDecode(raw) as Map);
    per.forEach((s, v) {
      c += v[0];
      a += v[1];
      final cur = (m[s] as List?)?.map((e) => e as int).toList() ?? [0, 0];
      m[s] = [cur[0] + v[0], cur[1] + v[1]];
    });
    await p.setString('subj', jsonEncode(m));
    await p.setInt('correct', (p.getInt('correct') ?? 0) + c);
    await p.setInt('attempted', (p.getInt('attempted') ?? 0) + a);
    await p.setInt('tests', (p.getInt('tests') ?? 0) + 1);
    final h = p.getStringList('hist') ?? [];
    h.insert(0, '${DateTime.now().toIso8601String()}|$title|$c|$a');
    if (h.length > 30) h.removeRange(30, h.length);
    await p.setStringList('hist', h);
  }

  /// [correct, attempted, tests, streak]
  static Future<List<int>> load() async {
    final p = await SharedPreferences.getInstance();
    return [
      p.getInt('correct') ?? 0,
      p.getInt('attempted') ?? 0,
      p.getInt('tests') ?? 0,
      await streak(),
    ];
  }

  static Future<Map<String, List<int>>> subjectStats() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('subj');
    if (raw == null) return {};
    final m = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    return m.map((k, v) =>
        MapEntry(k, (v as List).map((e) => e as int).toList()));
  }

  static Future<List<List<String>>> history() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList('hist') ?? [])
        .map((s) => s.split('|'))
        .where((l) => l.length == 4)
        .toList();
  }

  // ---------- Bookmarks ----------
  static String key(Question q) =>
      '${q.q}|${(List<String>.from(q.options)..sort()).join(',')}';

  static Future<bool> toggleBookmark(Question q) async {
    final p = await SharedPreferences.getInstance();
    final l = p.getStringList('bm') ?? [];
    final k = key(q);
    final i = l.indexWhere((s) => (jsonDecode(s) as Map)['k'] == k);
    if (i >= 0) {
      l.removeAt(i);
      await p.setStringList('bm', l);
      return false;
    }
    l.add(jsonEncode({'k': k, 'q': q.q, 'o': q.options, 'a': q.answer}));
    await p.setStringList('bm', l);
    return true;
  }

  static Future<Set<String>> bookmarkKeys() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList('bm') ?? [])
        .map((s) => (jsonDecode(s) as Map)['k'] as String)
        .toSet();
  }

  static Future<List<Question>> bookmarks() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList('bm') ?? []).map((s) {
      final m = jsonDecode(s) as Map;
      return Question(m['q'] as String, List<String>.from(m['o'] as List),
          m['a'] as int);
    }).toList();
  }

  // ---------- Daily streak ----------
  static String _day(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  static Future<int> streak() async {
    final p = await SharedPreferences.getInstance();
    final last = p.getString('lastDay');
    final s = p.getInt('streak') ?? 0;
    if (last == null) return 0;
    final now = DateTime.now();
    if (last == _day(now) ||
        last == _day(now.subtract(const Duration(days: 1)))) {
      return s;
    }
    return 0;
  }

  static Future<void> markDaily() async {
    final p = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = _day(now);
    final last = p.getString('lastDay');
    if (last == today) return;
    final y = _day(now.subtract(const Duration(days: 1)));
    final s = last == y ? (p.getInt('streak') ?? 0) + 1 : 1;
    await p.setInt('streak', s);
    await p.setString('lastDay', today);
  }
}
