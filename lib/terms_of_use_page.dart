import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Terms of Use

1. Acceptance of Terms

By installing and using this app, you agree to be bound by these Terms of Use and all applicable laws. If you do not agree, you are prohibited from using the application and must uninstall it immediately.
2. Software License

We grant you a limited, non-exclusive, non-transferable license to use this software for [personal/commercial] use. You may not:

    Reverse engineer, decompile, or attempt to extract the source code of the app.

    Redistribute or "mirror" the software on any other server or platform.

    Remove any copyright or proprietary notations from the software.

3. Absolute Data Responsibility (The "Zero-Server" Disclaimer)

You acknowledge that this app is a local-only application.

    No Backups: We do not host servers, store your data, or maintain backups.

    Loss of Access: If you delete the app, lose your device, or experience hardware failure, your data will be permanently lost.

    User Obligation: You are solely responsible for securing your own data via device-level backups (e.g., iCloud, Google Drive) or manual exports provided within the app.

4. Disclaimer of Warranty

The app is provided "AS IS" and "AS AVAILABLE." We disclaim all warranties, express or implied, including without limitation the warranties of merchantability, fitness for a particular purpose, and non-infringement. We do not warrant that the app will be error-free or that any errors will be corrected.
5. Limitation of Liability

In no event shall we be liable for any damages (including, without limitation, damages for loss of data, loss of profit, or business interruption) arising out of the use or inability to use the app. This applies even if we have been notified of the possibility of such damage.
6. Accuracy of Functionality

While we strive for technical accuracy, the software may contain technical, typographical, or logic errors. We do not warrant that any output of the app is accurate, complete, or current. We may make changes to the app at any time without notice but make no commitment to provide updates.
7. Governing Law

These terms are governed by the laws of Switzerland, and you irrevocably submit to the exclusive jurisdiction of the courts in that location.
''',
        ),
      ),
    );
  }
}
