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
1. Terms

By accessing our app, you are agreeing to be bound by these terms of service, all applicable laws and regulations, and agree that you are responsible for compliance with any applicable local laws. If you do not agree with any of these terms, you are prohibited from using or accessing this app. The materials contained in this app are protected by applicable copyright and trademark law.

2. Use License

Permission is granted to temporarily download one copy of the materials (information or software) on this app for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:

modify or copy the materials;
use the materials for any commercial purpose, or for any public display (commercial or non-commercial);
attempt to decompile or reverse engineer any software contained on this app;
remove any copyright or other proprietary notations from the materials; or
transfer the materials to another person or “mirror” the materials on any other server.

This license shall automatically terminate if you violate any of these restrictions and may be terminated by this app at any time. Upon terminating your viewing of these materials or upon the termination of this license, you must destroy any downloaded materials in your possession whether in electronic or printed format.

3. Disclaimer

The materials on this app are provided on an ‘as is’ basis. This app makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.

Further, this app does not warrant or make any representations concerning the accuracy, likely results, or reliability of the use of the materials on its app or otherwise relating to such materials or on any sites linked to this app.

4. Limitations

In no event shall this app or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on this app, even if this app or a this app authorized representative has been notified orally or in writing of the possibility of such damage. Because some jurisdictions do not allow limitations on implied warranties, or limitations of liability for consequential or incidental damages, these limitations may not apply to you.

5. Accuracy of materials

The materials appearing on this app could include technical, typographical, or photographic errors. This app does not warrant that any of the materials on its app are accurate, complete or current. This app may make changes to the materials contained on its app at any time without notice. However this app does not make any commitment to update the materials.

6. Links

This app has not reviewed all of the sites linked to its app and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by this app of the site. Use of any such linked website is at the user’s own risk.

7. Modifications

This app may revise these terms of service for its app at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.

8. Governing Law

These terms and conditions are governed by and construed in accordance with the laws of our country and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.
''',
        ),
      ),
    );
  }
}
