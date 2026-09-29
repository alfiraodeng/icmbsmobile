import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/top_bar.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _webViewCtrl = WebViewController();

  @override
  void initState() {
    super.initState();

    _webViewCtrl.loadHtmlString('''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <title>About MBS SAP</title>
      <style>
        h1, p, ul, li {
          font-size: 40px;
          margin: 0;
        }
        h1 {
          margin-bottom: 20px;
        }
        p, ul {
          margin-bottom: 50px;
        }
      </style>
    </head>
    <body>
      <h1>About MBS SAP</h1>
      <p>MBS SAP (Mobile Safety Accountability Program) is a mobile application developed by PT INDEXIM COALINDO to support occupational safety management and employee accountability.</p>
      <p>MBS SAP helps employees report safety activities, monitor follow-up actions, and access safety performance information from one application.</p>
      <h1>Key Features</h1>
      <h1>1.Real-time Safety Monitoring</h1>
      <ul>
      <li>Track and monitor safety incidents in real-time.</li>
      <li>Immediate reporting and alerts for any safety hazards.</li>
      </ul>
      <h1>2. SAP Performance</h1>
      <ul>
      <li>Monitor SAP achievement and quality.</li>
      <li>View league standings and employee safety performance.</li>
      </ul>
      <h1>3. Incident Reporting</h1>
      <ul>
      <li>Easy and quick reporting of safety incidents via the mobile app.</li>
      <li>Include photos, descriptions, and location data in incident reports.</li>
      </ul>
      <h1>4. Action Plan</h1>
      <ul>
      <li>Create and monitor corrective action plans.</li>
      <li>Track assigned persons, due dates, progress, and completion.</li>
      </ul>
      <h1>5. Information and Reporting</h1>
      <ul>
      <li>Generate detailed reports on safety performance and incidents.</li>
      <li>Access incident information and SAP work roster data.</li>
      </ul>
      <h1>6. Benefits</h1>
      <ul>
      <li>Enhanced Safety Culture</li>
      <li>Promotes a proactive safety culture within the company.</li>
      <li>Empowers employees to take responsibility for their own safety and that of their colleagues.</li>
      <li>Improved Compliance</li>
      <li>Ensures compliance with safety regulations and standards.</li>
      <li>Streamlines safety documentation and record-keeping.</li>
      <li>Efficient Incident Management</li>
      <li>Reduces response time to safety incidents.</li>
      <li>Facilitates efficient and effective incident management and resolution.</li>
      </ul>
      <h1>7. Technology</h1>
      <ul>
      <li>User-friendly Interface</li>
      <li>Intuitive and easy-to-navigate interface for all users.</li>
      <li>Designed for use in challenging environments, including remote mining sites.</li>
      <li>Secure and Reliable</li>
      <li>Robust security features to protect sensitive safety data.</li>
      <li>Reliable performance even in low connectivity areas.</li>
      <li>Cross-platform Compatibility</li>
      <li>Available on both Android and iOS platforms.</li>
      <li>Seamlessly integrates with existing company systems and infrastructure.</li>
      </ul>
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
      appBar: const TopBar(title: 'About MBS SAP'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: WebViewWidget(controller: _webViewCtrl),
      ),
    );
  }
}
