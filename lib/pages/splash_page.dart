import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/api.dart';
import '../services/preference.dart';
import '../utils/globals.dart' as globals;
import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _api = ApiService();
  final _auth = PreferenceService.getAuth();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      globals.appName = packageInfo.appName;
      globals.packageName = packageInfo.packageName;
      globals.version = packageInfo.version;
      globals.buildNumber = packageInfo.buildNumber;

      Future.delayed(const Duration(milliseconds: 1000), () async {
        if (_auth != null && _auth!.token != null) {
          _api.setToken = _auth!.token!;
          globals.currentPage = 0;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        } else {
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/images/progress.gif'),
          width: 150,
        ),
      ),
    );
  }
}
