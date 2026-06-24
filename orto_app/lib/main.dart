import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const OrtoSmartApp());
}

class OrtoSmartApp extends StatelessWidget {
  const OrtoSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orto Smart',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Orto Smart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              '📍 Pasiano di Pordenone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 24),

            Text(
              '📋 Attività di oggi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            ListTile(
              leading: Icon(Icons.water_drop),
              title: Text('Irrigare pomodori'),
            ),

            SizedBox(height: 24),

            Text(
              '🌿 Colture attive',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            ListTile(
              leading: Text('🍅'),
              title: Text('Pomodoro'),
            ),

            SizedBox(height: 24),

            Text(
              '🧺 Prossime raccolte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            ListTile(
              leading: Text('🍅'),
              title: Text('Pomodoro'),
              subtitle: Text('Tra 90 giorni'),
            ),
          ],
        ),
      ),
    );
  }
}