import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final User benutzer;

  const HomeScreen({super.key, required this.benutzer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startseite'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Abmelden',
            onPressed: () => _abmeldenBestaetigen(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Begrüßungskarte
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      benutzer.benutzername[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Willkommen!',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          benutzer.benutzername,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Benutzerinformationen
          Text(
            'Kontodetails',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _InfoKachel(
            icon: Icons.badge_outlined,
            titel: 'Benutzer-ID',
            wert: '#${benutzer.id}',
          ),
          _InfoKachel(
            icon: Icons.person_outline_rounded,
            titel: 'Benutzername',
            wert: benutzer.benutzername,
          ),
          _InfoKachel(
            icon: Icons.email_outlined,
            titel: 'E-Mail-Adresse',
            wert: benutzer.email,
          ),
          _InfoKachel(
            icon: Icons.calendar_today_outlined,
            titel: 'Registriert am',
            wert: benutzer.erstelltAm,
          ),
          const SizedBox(height: 24),

          // Platzhalter-Inhalt
          Text(
            'Inhalte',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.widgets_outlined,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hier kommt Ihr App-Inhalt',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _abmeldenBestaetigen(BuildContext context) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abmelden'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (bestaetigt == true && context.mounted) {
      await AuthService().abmelden();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }
}

class _InfoKachel extends StatelessWidget {
  final IconData icon;
  final String titel;
  final String wert;

  const _InfoKachel({
    required this.icon,
    required this.titel,
    required this.wert,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          titel,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        subtitle: Text(
          wert,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
