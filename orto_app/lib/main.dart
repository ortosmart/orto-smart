import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';

import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/garden_page.dart';
import 'pages/irrigation_page.dart';
import 'pages/activities_page.dart';
import 'pages/settings_page.dart';

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
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    GardenPage(),
    IrrigationPage(),
    ActivitiesPage(),
    SettingsPage(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Orto',
    'Irrigazione',
    'Attività',
    'Impostazioni',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grass),
            label: 'Orto',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop),
            label: 'Irrigazione',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Attività',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}