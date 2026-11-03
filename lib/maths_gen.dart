import 'dart:math';
import 'questions.dart';

final Random _r = Random();

int _ri(int a, int b) => a + _r.nextInt(b - a + 1);

Question _mk(String q, int correct, {String unit = ''}) {
  final set = <int>{correct};
  int guard = 0;
  while (set.length < 4 && guard < 200) {
    guard++;
    final d = _ri(1, 6) * (correct.abs() >= 50 ? _ri(2, 10) : 1);
    final cand = _r.nextBool() ? correct + d : correct - d;
    if (cand > 0) set.add(cand);
  }
  int k = 1;
  while (set.length < 4) {
    set.add(correct + k++);
  }
  final opts = set.toList()..shuffle(_r);
  return Question(
      q, opts.map((e) => '$e$unit').toList(), opts.indexOf(correct));
}

Question _percentage() {
  const ps = [5, 10, 15, 20, 25, 30, 40, 50, 60, 75];
  final p = ps[_r.nextInt(ps.length)];
  final base = _ri(2, 50) * 20;
  return _mk('$p% of $base = ?', (base ~/ 20) * (p ~/ 5));
}

Question _average() {
  final a = _ri(30, 70);
  final n = _ri(4, 6);
  final nums = <int>[];
  var sum = 0;
  for (int i = 0; i < n - 1; i++) {
    final x = a + _ri(-5, 5);
    nums.add(x);
    sum += x;
  }
  nums.add(n * a - sum);
  nums.shuffle(_r);
  return _mk('Average of ${nums.join(', ')} = ?', a);
}

Question _timeWork() {
  const pairs = [
    [10, 15], [12, 24], [20, 30], [15, 30], [12, 36],
    [30, 60], [18, 36], [10, 40], [20, 60], [24, 48]
  ];
  final p = pairs[_r.nextInt(pairs.length)];
  final a = p[0], b = p[1];
  return _mk(
      'A can do a work in $a days and B in $b days. Together they finish it in how many days?',
      a * b ~/ (a + b),
      unit: ' din');
}

Question _hcfLcm() {
  const pairs = [
    [2, 3], [3, 4], [2, 5], [3, 5], [4, 5], [5, 6], [3, 7], [2, 7]
  ];
  final p = pairs[_r.nextInt(pairs.length)];
  final g = _ri(2, 12);
  final x = g * p[0], y = g * p[1];
  if (_r.nextBool()) return _mk('HCF of $x and $y = ?', g);
  return _mk('LCM of $x and $y = ?', g * p[0] * p[1]);
}

Question _profit() {
  const ps = [5, 10, 20, 25];
  final p = ps[_r.nextInt(ps.length)];
  final cp = _ri(5, 60) * 20;
  final sp = (cp ~/ 20) * ((100 + p) ~/ 5);
  return _mk('Cost price Rs $cp, profit $p%. Selling price = ?', sp);
}

Question _si() {
  final pr = _ri(1, 20) * 1000;
  final r = _ri(2, 12);
  final t = _ri(1, 5);
  return _mk('Simple interest on Rs $pr at $r% per year for $t years = ?',
      pr * r * t ~/ 100);
}

Question _sdt() {
  final s = _ri(4, 18) * 5;
  final t = _ri(2, 8);
  return _mk('A car runs at $s km/h for $t hours. Distance = ?', s * t,
      unit: ' km');
}

Question _ratio() {
  const rs = [
    [2, 3], [3, 4], [1, 2], [2, 5], [3, 5], [4, 5]
  ];
  final p = rs[_r.nextInt(rs.length)];
  final k = _ri(10, 100);
  final total = k * (p[0] + p[1]);
  final big = k * (p[0] > p[1] ? p[0] : p[1]);
  return _mk(
      'Rs $total is divided in the ratio ${p[0]}:${p[1]}. The larger share = ?',
      big);
}

Question _square() {
  final n = _ri(11, 40);
  if (_r.nextBool()) return _mk('Square of $n = ?', n * n);
  return _mk('Square root of ${n * n} = ?', n);
}

Question _series() {
  if (_r.nextBool()) {
    final a = _ri(1, 20), d = _ri(2, 9);
    final s = [for (int i = 0; i < 4; i++) a + d * i];
    return _mk('Next number: ${s.join(', ')}, ?', a + d * 4);
  }
  final a = _ri(1, 5), m = _ri(2, 4);
  final s = [for (int i = 0; i < 4; i++) a * pow(m, i).toInt()];
  return _mk('Next number: ${s.join(', ')}, ?', a * pow(m, 4).toInt());
}

List<Question> _gen(Question Function() f, int n) =>
    List.generate(n, (_) => f());

Map<String, List<Question>>? withGenerated(String subject) {
  final base = bank[subject];
  if (subject == 'Maths') {
    return {
      ...?base,
      'Practice: Percentage': _gen(_percentage, 20),
      'Practice: Average': _gen(_average, 20),
      'Practice: Time & Work': _gen(_timeWork, 20),
      'Practice: HCF & LCM': _gen(_hcfLcm, 20),
      'Practice: Profit & Loss': _gen(_profit, 20),
      'Practice: Simple Interest': _gen(_si, 20),
      'Practice: Speed & Distance': _gen(_sdt, 20),
      'Practice: Ratio': _gen(_ratio, 20),
      'Practice: Squares & Roots': _gen(_square, 20),
    };
  }
  if (subject == 'Reasoning') {
    return {
      ...?base,
      'Practice: Number Series': _gen(_series, 20),
    };
  }
  return base;
}
