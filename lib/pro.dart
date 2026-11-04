import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class Pro {
  static bool active = false;

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    active = p.getBool('pro') ?? false;
  }

  /// Abhi sirf test ke liye. Play Billing judne par yahan se hata denge.
  static Future<void> setTest(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('pro', v);
    active = v;
  }

  static bool locked(String subject, [String? chapter]) {
    if (active || AppConfig.allFree) return false;
    if (AppConfig.proItems.contains(subject)) return true;
    if (chapter != null && AppConfig.proItems.contains('$subject|$chapter')) {
      return true;
    }
    return false;
  }
}

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});
  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master AIO Pro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.workspace_premium, size: 80, color: Colors.amber),
          const SizedBox(height: 12),
          Center(
            child: Text(Pro.active ? 'Pro chalu hai' : 'Pro mein kya milega',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          const ListTile(
              leading: Icon(Icons.check), title: Text('Poori Mock Test series')),
          const ListTile(
              leading: Icon(Icons.check), title: Text('Purane saal ke paper')),
          const ListTile(
              leading: Icon(Icons.check), title: Text('Gehri Analytics')),
          const ListTile(
              leading: Icon(Icons.check), title: Text('PDF notes aur formula book')),
          const ListTile(leading: Icon(Icons.check), title: Text('Bina vigyapan')),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Payment jald hi Google Play se shuru hoga. Abhi yeh sirf jaanch ke liye hai.'),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              await Pro.setTest(!Pro.active);
              if (mounted) setState(() {});
            },
            child: Text(Pro.active
                ? '[Test] Pro band karo'
                : '[Test] Pro chalu karo'),
          ),
        ],
      ),
    );
  }
}
