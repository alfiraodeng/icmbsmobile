import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/link_model.dart';
import '../services/preference.dart';
import '../utils/links.dart';
import '../utils/routers.dart';
import 'menu/extra_page.dart';
import 'menu/ohs_page.dart';
import 'menu/sap_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _profile = PreferenceService.getProfile();
  final List<LinkMenuModel> _rawData = [
    ...listMenuSap,
    ...listMenuOhs1,
    ...listMenuOhs2,
    ...listMenuExtra
  ];
  final List<String> _searchList = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _searchList.addAll({
          for (var row in _rawData.toList()) row.title.replaceAll('\n', ' ')
        }.toList());
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          title: Container(
            margin: const EdgeInsets.only(top: 30),
            child: Stack(
              children: [
                Visibility(
                  visible: (_searchText == ''),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text('Search...', style: TextStyle(fontSize: 18)),
                  ),
                ),
                Autocomplete(
                  optionsBuilder: (TextEditingValue txtValue) {
                    setState(() => _searchText = txtValue.text);

                    if (txtValue.text == '') {
                      return const Iterable<String>.empty();
                    }

                    return _searchList.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(txtValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    var vals = _rawData
                        .where(
                            (e) => e.title.replaceAll('\n', ' ') == selection)
                        .toList();
                    if (vals.isNotEmpty) {
                      routePage(context, vals.first.route,
                          title: vals.first.title);
                    }
                  },
                  initialValue: const TextEditingValue(text: ''),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Hai, ${_profile?.namaLengkap}'.toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Semangat pagi! pagi semangat luar biasa',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/header-home.png'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                child: Image.asset(
                  'assets/images/header-home.png',
                  fit: BoxFit.fitWidth,
                  opacity: const AlwaysStoppedAnimation(0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        border: Border.all(color: Colors.indigo.shade200),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/sap.png',
                            fit: BoxFit.fitHeight,
                            height: 55,
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'SAP',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => const SapPage(),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        border: Border.all(color: Colors.indigo.shade200),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ohs.png',
                            fit: BoxFit.fitHeight,
                            height: 55,
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'OHS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => const OhsPage(),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        border: Border.all(color: Colors.indigo.shade200),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/extras.png',
                            fit: BoxFit.fitHeight,
                            height: 55,
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Extra\'s',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => const ExtraPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  onPageChanged: (index, reason) {},
                  viewportFraction: 1,
                  animateToClosest: true,
                ),
                items: listNews().map((element) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          image: DecorationImage(
                            image: AssetImage(element.image ?? ''),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        child: Image.asset(
                          element.image ?? '',
                          fit: BoxFit.fitWidth,
                          opacity: const AlwaysStoppedAnimation(0),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 75),
          ],
        ),
      ),
    );
  }
}
