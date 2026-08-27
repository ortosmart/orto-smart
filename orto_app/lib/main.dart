import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/identity/app_identity_service.dart';
import 'core/profile/profile_session_gate.dart';
import 'core/profile/profile_context.dart';
import 'core/write_authority/profile_write_authority_controller.dart';
import 'core/write_authority/write_authority_scheduler.dart';
import 'data/repositories/profile_context_repository.dart';
import 'data/repositories/profile_edit_lock_repository.dart';

import 'pages/dashboard_page.dart';
import 'pages/garden_page.dart';
import 'pages/irrigation_page.dart';
import 'pages/activities_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';

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
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session != null) {
          return _AuthenticatedProfileSession(key: ValueKey(session.user.id));
        }

        return const LoginPage();
      },
    );
  }
}

class _AuthenticatedProfileSession extends StatelessWidget {
  const _AuthenticatedProfileSession({super.key});

  @override
  Widget build(BuildContext context) {
    final profileContextRepository = ProfileContextRepository();
    final identityService = AppIdentityService.sharedPreferences();

    return ProfileSessionGate(
      resolveProfileContext:
          profileContextRepository.resolveSingleProfileContext,
      createSessionIdentity: identityService.createSessionIdentity,
      createController: () {
        return ProfileWriteAuthorityController(
          ProfileEditLockRepository(),
          const TimerWriteAuthorityScheduler(),
        );
      },
      loading: const Scaffold(body: Center(child: CircularProgressIndicator())),
      failureBuilder: (context, failure, retry) {
        return _ProfileSessionFailure(
          message: _profileSessionFailureMessage(failure),
          onRetry: retry,
        );
      },
      child: const HomePage(),
    );
  }
}

String _profileSessionFailureMessage(Object failure) {
  if (failure is ProfileContextException) {
    return switch (failure.failure) {
      ProfileContextFailure.notAuthenticated =>
        'La sessione non è più autenticata.',
      ProfileContextFailure.membershipNotFound =>
        'Nessun profilo attivo è associato a questo account.',
      ProfileContextFailure.ambiguousMembership =>
        'Sono presenti più profili attivi per questo account.',
      ProfileContextFailure.invalidMembership =>
        'I dati del profilo associato non sono validi.',
    };
  }

  return 'Non è stato possibile preparare il profilo.';
}

class _ProfileSessionFailure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileSessionFailure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
              ),
            ],
          ),
        ),
      ),
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
      appBar: AppBar(title: Text(_titles[_selectedIndex]), centerTitle: true),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grass), label: 'Orto'),
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
