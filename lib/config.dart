import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Yeh file GitHub par rakho (repo Public hona chahiye).
const String remoteUrl =
    'https://raw.githubusercontent.com/Nitin-study/master_aio/main/assets/config.json';

class AppConfig {
  /// Pro wale subjects ya chapters. Format: "Subject" ya "Subject|Chapter"
  static Set<String> proItems = {};
  static String message = '';
  static int minVersion = 1;
  static bool allFree = false;

  static const int appVersion = 1;
  static bool get mustUpdate => appVersion < minVersion;

  static void _apply(Map<String, dynamic> m) {
    proItems = ((m['pro'] as List?) ?? []).map((e) => e.toString()).toSet();
    message = (m['message'] as String?) ?? '';
    minVersion = (m['minVersion'] as int?) ?? 1;
    allFree = (m['allFree'] as bool?) ?? false;
  }

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    // 1) pehle app ke andar wali file
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      _apply(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {}
    // 2) phir pichhli online copy
    final cached = p.getString('cfg');
    if (cached != null) {
      try {
        _apply(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    // 3) phir naya online (internet na ho to chhod do)
    try {
      final r = await http
          .get(Uri.parse(remoteUrl))
          .timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        final m = jsonDecode(r.body) as Map<String, dynamic>;
        _apply(m);
        await p.setString('cfg', r.body);
      }
    } catch (_) {}
  }
}
