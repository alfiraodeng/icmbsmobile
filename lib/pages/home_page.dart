import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api.dart';
import '../services/preference.dart';
import '../utils/globals.dart' as globals;
import 'dashboard_page.dart';
import 'hazard/hazard_form_page.dart';
import 'profile_page.dart';
import 'safety_updates_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _pageCtrl = PageController(initialPage: globals.currentPage);
  final _api = ApiService();
  final _profile = PreferenceService.getProfile();
  int _currentPage = globals.currentPage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bgToken', _api.getToken);
      await prefs.setInt('bgProfile', (_profile?.id ?? 0));
    });
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  void _showBackDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar Aplikasi'),
          content: const Text(
            'Apakah anda akan keluar aplikasi?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (Platform.isAndroid) {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  } else if (Platform.isIOS) {
                    exit(0);
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _showBackDialog();
      },
      child: Scaffold(
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
              globals.currentPage = page;
            });
          },
          children: const [
            DashboardPage(),
            SafetyUpdatesPage(),
            SizedBox.shrink(),
            ProfilePage(),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: bottomNavBar(),
        // floatingActionButton: FloatingActionButton(
        //   elevation: 12,
        //   shape: const CircleBorder(),
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => const HazardFormPage(),
        //       ),
        //     );
        //   },
        //   tooltip: 'Quick',
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        //   child: Image.asset(
        //     'assets/images/quick-hazard.png',
        //     height: 72,
        //     fit: BoxFit.cover,
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      ),
    );
  }

  Widget bottomNavBar() {
    return SizedBox(
      height: 104,
      child: BottomNavigationBar(
        iconSize: 28,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_rounded, size: 28),
            label: 'Safety Updates',
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage('assets/images/quick-hazard.png'),
              height: 30,
            ),
            label: 'Quick Hazard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profil',
          ),
        ],
        currentIndex: _currentPage,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HazardFormPage(),
              ),
            );
            return;
          }
          _pageCtrl.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}
