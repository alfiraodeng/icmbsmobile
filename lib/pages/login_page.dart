import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/api.dart';
import '../services/background.dart';
import '../services/database.dart';
import '../services/preference.dart';
import '../utils/globals.dart' as globals;
import '../utils/helpers.dart';
import '../widgets/button_app.dart';
import '../widgets/snackbar_msg.dart';
import 'home_page.dart';
import 'sync_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final _db = DatabaseService();
  final _api = ApiService();
  final _profile = PreferenceService.getProfile();
  final _userCtrl = TextEditingController();
  final _pswdCtrl = TextEditingController();
  String _version = '';
  bool _remember = true;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() => _version = packageInfo.version);

      BackgroundService.instance.isRunning().then((val) {
        if (!val) BackgroundService.instance.start();
      });

      _userCtrl.text = PreferenceService.getUser() ?? '';
      _pswdCtrl.text = PreferenceService.getPassword() ?? '';
    });
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  void _login() {
    if (_key.currentState != null && _key.currentState!.validate()) {
      _key.currentState?.save();
      _api.login(_userCtrl.text, _pswdCtrl.text).then((res) {
        res.fold((error) async {
          if (error['message'] == 'No internet access!') {
            if (_remember) {
              PreferenceService.setUserPassword(_userCtrl.text, _pswdCtrl.text);
            } else {
              PreferenceService.setUserPassword('', '');
            }
            var row = await _db.rawQuery(
                "select id from employees where updated_at is not null and no_nik='${_userCtrl.text}' limit 1");
            if (row.isNotEmpty && row[0]['no_nik'] == _profile?.noNik) {
              globals.currentPage = 0;
              if (!mounted) return;
              await Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            } else {
              if (!mounted) return;
              SnackBarMsg.danger(context, 'Invalid local account!');
            }
          } else {
            SnackBarMsg.danger(context, error['message'].toString());
          }
        }, (response) async {
          PreferenceService.setAuth(response);
          if (_remember) {
            PreferenceService.setUserPassword(_userCtrl.text, _pswdCtrl.text);
          } else {
            PreferenceService.setUserPassword('', '');
          }
          _api.getProfile().then((res) {
            res.fold((error) {
              debugPrint(error['message'].toString());
            }, (response) async {
              PreferenceService.setProfile(response);
              globals.currentPage = 0;
              var dataSync = PreferenceService.getDataSync();
              if (dataSync != null && dataSync.length >= 12) {
                if (!mounted) return;
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              } else {
                if (!mounted) return;
                await Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SyncPage(response)),
                  (route) => false,
                );
              }
            });
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Form(
                key: _key,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    const Center(
                      child: Image(
                        image: AssetImage('assets/images/logo-mbs.png'),
                        width: 130,
                      ),
                    ),
                    const Center(
                      child: Image(
                        image: AssetImage('assets/images/indexsafe-slogan.png'),
                        width: 180,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Halo Semangat Pagi!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _userCtrl,
                      decoration: InputDecoration(
                        labelText: 'NIK',
                        labelStyle: const TextStyle(fontSize: 18),
                        prefixIcon: Container(
                          alignment: Alignment.centerLeft,
                          width: 28,
                          child: const Icon(
                            Icons.account_circle,
                            size: 28,
                            color: Colors.indigo,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(fontSize: 18),
                      validator: validator,
                      onChanged: (String val) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _pswdCtrl,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(fontSize: 18),
                        prefixIcon: Container(
                          alignment: Alignment.centerLeft,
                          width: 28,
                          child: const Icon(
                            Icons.key,
                            size: 28,
                            color: Colors.indigo,
                          ),
                        ),
                        suffixIcon: Container(
                          alignment: Alignment.centerRight,
                          width: 28,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo),
                        ),
                      ),
                      style: const TextStyle(fontSize: 18),
                      obscureText: _obscureText,
                      validator: validator,
                      onChanged: (String val) => setState(() {}),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _remember,
                            activeColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            side: WidgetStateBorderSide.resolveWith(
                              (states) =>
                                  const BorderSide(color: Colors.indigo),
                            ),
                            onChanged: (bool? val) {
                              setState(() => _remember = val!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Remember Me',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  child: buttonApp(label: 'LOGIN', onPressed: _login),
                ),
                const SizedBox(height: 20),
                Text('Versi $_version')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
