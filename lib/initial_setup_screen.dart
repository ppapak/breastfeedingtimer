import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';

class InitialSetupScreen extends StatefulWidget {
  const InitialSetupScreen({super.key});

  @override
  State<InitialSetupScreen> createState() => _InitialSetupScreenState();
}

class _InitialSetupScreenState extends State<InitialSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _babyName = '';
  bool _hasAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Baby\'s Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your baby\'s name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _babyName = value!;
                  },
                ),
                const SizedBox(height: 20),
                CheckboxListTile(
                  value: _hasAgreed,
                  onChanged: (value) {
                    setState(() {
                      _hasAgreed = value!;
                    });
                  },
                  title: const Text(
                      'I understand that this app is a tracking tool only and that I must independently verify all feeding data before making care decisions.'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _hasAgreed
                      ? () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            final babyProvider = context.read<BabyProvider>();
                            final setupProvider =
                                context.read<SetupProvider>();
                            await babyProvider.setBabyName(_babyName);
                            await setupProvider.completeSetup();
                          }
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
