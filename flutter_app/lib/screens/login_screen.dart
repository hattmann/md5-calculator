import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwortCtrl = TextEditingController();
  final _authService = AuthService();

  bool _laedt = false;
  String? _fehler;
  bool _passwortSichtbar = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwortCtrl.dispose();
    super.dispose();
  }

  Future<void> _anmelden() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _laedt = true;
      _fehler = null;
    });

    final ergebnis = await _authService.login(
      _emailCtrl.text.trim(),
      _passwortCtrl.text,
    );

    if (!mounted) return;
    setState(() => _laedt = false);

    if (ergebnis.erfolg) {
      _navigiereZuStartseite(ergebnis.benutzer!);
    } else {
      setState(() => _fehler = ergebnis.fehler);
    }
  }

  void _navigiereZuStartseite(User benutzer) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(benutzer: benutzer)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Anmelden',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bitte melden Sie sich an',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Fehleranzeige
                    if (_fehler != null) ...[
                      _FehlerBox(nachricht: _fehler!),
                      const SizedBox(height: 16),
                    ],

                    // E-Mail
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-Mail-Adresse',
                        hintText: 'beispiel@email.de',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Bitte E-Mail eingeben';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Ungültige E-Mail-Adresse';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Passwort
                    TextFormField(
                      controller: _passwortCtrl,
                      obscureText: !_passwortSichtbar,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _anmelden(),
                      decoration: InputDecoration(
                        labelText: 'Passwort',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwortSichtbar
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(
                            () => _passwortSichtbar = !_passwortSichtbar,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Bitte Passwort eingeben';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Anmelde-Button
                    FilledButton(
                      onPressed: _laedt ? null : _anmelden,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _laedt
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Anmelden',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FehlerBox extends StatelessWidget {
  final String nachricht;
  const _FehlerBox({required this.nachricht});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              nachricht,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
