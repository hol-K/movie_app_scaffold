import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'eve.holt@reqres.in');
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.register)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Note pédagogique : l'API factice ReqRes n'accepte que
                // certains emails "fixture" en /register (voir README).
                const Text(
                  'Démo : utilise un email fixture ReqRes ',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                      labelText: strings.email,
                      border: const OutlineInputBorder()),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? strings.invalidEmail
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                    decoration: InputDecoration(
                      labelText: strings.password,
                      border: const OutlineInputBorder()),
                  validator: (v) => (v == null || v.length < 4)
                      ? strings.passwordTooShort
                      : null,
                ),
                const SizedBox(height: 24),
                if (auth.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(auth.errorMessage!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                FilledButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(strings.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context
        .read<AuthProvider>()
        .register(_emailController.text.trim(), _passwordController.text);
    if (ok && mounted) Navigator.of(context).pop();
  }
}
