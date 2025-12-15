import 'package:flutter/material.dart';

import 'privacy_policy_page.dart';
import 'terms_of_use_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Terms of Use'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfUsePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
