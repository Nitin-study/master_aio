import 'dart:convert';
import 'package:flutter/services.dart';
import 'questions.dart';

/// Nayi JSON file banao to uska naam yahan jodna hai (bina .json ke)
const _files = ['jk_gk'];

final Map<String, Map<String, List<Question>>> extra = {};
final Map<String, int> chapterYear = {};
final Map<String, String> explain = {};

class SQ {
  final String subject;
  final Question q;
  SQ(this.subject, this.q);
}

Future<void> loadExtra() async {
  for (final f in _files) {
    try {
      final raw = await rootBundle.loadString('assets/questions/$f.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final subject = data['subject'] as String;
      final year = (data['year'] as int?) ?? 0;
      final chapters = data['chapters'] as Map<String, dynamic>;
      final target = extra.putIfAbsent(subject, () => {});
      chapters.forEach((name, list) {
        final qs = target.putIfAbsent(name, () => <Question>[]);
        if (year != 0) chapterYear['$subject|$name'] = year;
        for (final m in list as List) {
          final q = m['q'] as String;
          qs.add(Question(
              q, List<String>.from(m['o'] as List), m['a'] as int));
          final e = m['e'];
          if (e is String && e.isNotEmpty) explain[q] = e;
        }
      });
    } catch (_) {
      // kharab ya missing file ko chhod do, app na ruke
    }
  }
}

Map<String, List<Question>>? mergedChapters(String subject) {
  final out = <String, List<Question>>{};
  bank[subject]?.forEach((k, v) => out[k] = List<Question>.from(v));
  extra[subject]?.forEach((k, v) {
    out.putIfAbsent(k, () => <Question>[]).addAll(v);
  });
  return out.isEmpty ? null : out;
}

List<Question> allQuestions() => allSQ().map((e) => e.q).toList();

List<SQ> allSQ() {
  final out = <SQ>[];
  for (final s in {...bank.keys, ...extra.keys}) {
    mergedChapters(s)?.values.forEach((l) {
      for (final q in l) {
        out.add(SQ(s, q));
      }
    });
  }
  return out;
}
