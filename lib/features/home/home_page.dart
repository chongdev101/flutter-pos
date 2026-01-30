import 'package:flutter/material.dart';
import '../../core/security/rasp/rasp_threat_handler.dart';
import '../rasp_poc/rasp_flutter_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // ensure any pending threat is displayed once first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RaspThreatHandler.showPendingIfAny();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Home Page')),
      body: ListView(
        children: [
          _menuItem(
            title: 'RASP Flutter Demo Page',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RASPFlutterPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
