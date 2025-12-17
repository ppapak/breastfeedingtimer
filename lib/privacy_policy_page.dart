import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Privacy Policy

Last Updated: [Insert Date]
1. Data Sovereignty

This app is built on the principle of local-first privacy. We do not operate servers to store your personal information. Every piece of data you create, input, or save stays exclusively on your device.
2. Zero Collection & Access

    No Personal Information: We do not collect, track, or request your name, email, location, or any other identifying data.

    No Tracking: There are no third-party analytics, advertising SDKs, or trackers embedded in this app.

    No Remote Access: We cannot see, access, or recover your data. If you delete the app or lose your device, your data is gone unless you have backed up your device via [e.g., iCloud/Google Drive].

3. Third-Party Services
 
This app allows you to export your data and you are interacting with third-party services governed by their own privacy policies. We do not control and are not responsible for how those entities handle your data once it leaves your device.

4. Data Security

Because your data is never transmitted to us, its security is entirely dependent on the security of your device. We recommend using standard device encryption and passcodes to protect your local information.
5. Compliance with Law

Since we possess zero user data, we have nothing to provide to law enforcement or government agencies, even if legally compelled. We cannot share what we do not have.
''',
        ),
      ),
    );
  }
}
