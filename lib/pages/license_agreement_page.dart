import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/top_bar.dart';

class LicenseAgreementPage extends StatefulWidget {
  const LicenseAgreementPage({super.key});

  @override
  State<LicenseAgreementPage> createState() => _LicenseAgreementPageState();
}

class _LicenseAgreementPageState extends State<LicenseAgreementPage> {
  final _webViewCtrl = WebViewController();

  @override
  void initState() {
    super.initState();

    _webViewCtrl.loadHtmlString('''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <title>License Agreement</title>
      <style>
        h1, p {
          font-size: 40px;
          margin: 0;
        }
        h1 {
          margin-bottom: 20px;
        }
        p {
          margin-bottom: 50px;
        }
      </style>
    </head>
    <body>
      <h1>MBS SAP License Agreement</h1>
      <p>This License Agreement governs the use of MBS SAP (Mobile Safety Accountability Program), hereinafter referred to as the "Application", developed and provided by PT INDEXIM COALINDO.</p>
      <h1>1. License Grant</h1>
      <p>The Company grants User a non-exclusive, non-transferable, revocable license to use the MBS SAP Application solely for internal business purposes related to safety and accountability within
      PT INDEXIM COALINDO.</p>
      <h1>2. Restrictions</h1>
      <p><strong>User shall not:</strong>
      Modify, adapt, translate, or create derivative works based on the Application.
      Reverse engineer, decompile, or disassemble the Application.
      Rent, lease, lend, sell, sublicense, or otherwise transfer any rights in the Application.
      Remove any proprietary notices or labels on the Application.</p>
      <h1>3. Ownership</h1>
      <p>MBS SAP is and shall remain the exclusive property of the Company. This Agreement does not grant User any ownership rights in the Application.</p>
      <h1>4. Confidentiality</h1>
      <p>User agrees to maintain the confidentiality of any proprietary information disclosed by the Company in connection with this Agreement. User shall not disclose such information to any third party without the prior written consent of the Company.</p>
      <h1>5. Updates and Maintenance</h1>
      <p>The Company may, at its discretion, provide updates or maintenance for MBS SAP. Any such updates or maintenance shall be subject to the terms of this Agreement.</p>
      <h1>6. Term and Termination</h1>
      <p>This Agreement is effective until terminated. The Company may terminate this Agreement at any time if User breaches any of its terms. Upon termination, User shall cease all use of MBS SAP and destroy any copies in their possession or control.</p>
      <h1>7. Warranty Disclaimer</h1>
      <p>MBS SAP is provided "as is," without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement. The Company does not warrant that the Application will meet User's requirements or that its operation will be uninterrupted or error-free.</p>
      <h1>8. Limitation of Liability</h1>
      <p>In no event shall the Company be liable for any indirect, incidental, special, or consequential damages, or damages for loss of profits, revenue, data, or use, incurred by User or any third party, whether in an action in contract or tort, arising from User's access to, or use of, MBS SAP.</p>
      <h1>9. Governing Law</h1>
      <p>This Agreement shall be governed by and construed in accordance with the laws of the Republic of Indonesia, without regard to its conflict of laws principles.</p>
      <h1>10. Entire Agreement</h1>
      <p>This Agreement constitutes the entire agreement between the parties concerning the subject matter hereof and supersedes all prior and contemporaneous understandings and agreements, whether written or oral, regarding such subject matter.</p>
      <h1>11. Severability</h1>
      <p>If any provision of this Agreement is found to be invalid or unenforceable, the remaining provisions shall remain in full force and effect.</p>
      <h1>12. Waiver</h1>
      <p>No waiver of any term of this Agreement shall be deemed a further or continuing waiver of such term or any other term.</p>
      <p><strong>IN WITNESS WHEREOF</strong>, the parties hereto have executed this License Agreement as of the date first written below.</p>
    </body>
    </html>
    ''');
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'MBS SAP License Agreement'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: WebViewWidget(controller: _webViewCtrl),
      ),
    );
  }
}
