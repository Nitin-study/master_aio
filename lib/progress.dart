import 'package:shared_preferences/shared_preferences.dart';

class Progress {
  static Future<void> add(int correct, int attempted) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('correct', (p.getInt('correct') ?? 0) + correct);
    await p.setInt('attempted', (p.getInt('attempted') ?? 0) + attempted);
    await p.setInt('tests', (p.getInt('tests') ?? 0) + 1);
  }

  static Future<List<int>> load() async {
    final p = await SharedPreferences.getInstance();
    return [
      p.getInt('correct') ?? 0,
      p.getInt('attempted') ?? 0,
      p.getInt('tests') ?? 0,
    ];
  }
}
