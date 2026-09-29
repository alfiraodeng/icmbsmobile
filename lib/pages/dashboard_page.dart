import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  final _hazardMapCtrl = WebViewController();
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

    _hazardMapCtrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(_hazardMapHtml());

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
                            'Performance\nHub',
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Heatmap Lokasi Temuan Bahaya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 320,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: WebViewWidget(
                        controller: _hazardMapCtrl,
                        gestureRecognizers: {
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 75),
          ],
        ),
      ),
    );
  }

  String _hazardMapHtml() {
    return r'''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
      <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
      <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
      <style>
        html, body, #map {
          height: 100%;
          width: 100%;
          margin: 0;
          padding: 0;
          overflow: hidden;
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        }
        .leaflet-control-layers,
        .leaflet-control-zoom {
          border: none !important;
          box-shadow: 0 8px 20px rgba(15, 23, 42, .16) !important;
        }
        .leaflet-popup-content-wrapper {
          border-radius: 14px;
        }
        .hazard-popup {
          width: 210px;
        }
        .hazard-popup img {
          width: 210px;
          height: 118px;
          object-fit: cover;
          border-radius: 10px;
          display: block;
          margin-bottom: 10px;
        }
        .hazard-popup h3 {
          font-size: 15px;
          line-height: 1.25;
          margin: 0 0 6px;
          color: #111827;
        }
        .hazard-popup p {
          font-size: 12px;
          line-height: 1.35;
          margin: 3px 0;
          color: #4b5563;
        }
        .badge {
          display: inline-block;
          padding: 3px 8px;
          border-radius: 999px;
          color: white;
          font-size: 11px;
          font-weight: 700;
          margin-bottom: 8px;
        }
        .legend {
          background: rgba(255,255,255,.95);
          padding: 8px 10px;
          border-radius: 12px;
          box-shadow: 0 8px 20px rgba(15, 23, 42, .14);
          font-size: 11px;
          color: #1f2937;
        }
        .legend-row {
          display: flex;
          align-items: center;
          gap: 6px;
          margin-top: 5px;
        }
        .dot {
          width: 10px;
          height: 10px;
          border-radius: 50%;
          display: inline-block;
        }
      </style>
    </head>
    <body>
      <div id="map"></div>
      <script>
        const street = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; OpenStreetMap'
        });

        const satellite = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
          maxZoom: 19,
          attribution: 'Tiles &copy; Esri'
        });

        const map = L.map('map', {
          center: [1.2057, 117.2247],
          zoom: 13,
          layers: [satellite],
          zoomControl: true,
          dragging: true,
          scrollWheelZoom: true,
          doubleClickZoom: true,
          touchZoom: true
        });

        L.control.layers({
          'Satelit': satellite,
          'Street': street
        }).addTo(map);

        const hazardPoints = [
          {
            title: 'Tumpahan oli di workshop',
            area: 'Workshop LV',
            level: 'Tinggi',
            color: '#ef4444',
            lat: 1.2118,
            lng: 117.2198,
            photo: 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=520&q=80',
            notes: 'Potensi terpeleset dan kontaminasi area kerja.'
          },
          {
            title: 'Material loose di hauling road',
            area: 'Hauling Road KM 4',
            level: 'Sedang',
            color: '#f59e0b',
            lat: 1.1997,
            lng: 117.2331,
            photo: 'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=520&q=80',
            notes: 'Butuh housekeeping dan rambu sementara.'
          },
          {
            title: 'Area kerja tanpa barricade',
            area: 'Pit Selatan',
            level: 'Kritis',
            color: '#b91c1c',
            lat: 1.1914,
            lng: 117.2145,
            photo: 'https://images.unsplash.com/photo-1516937941344-00b4e0337589?auto=format&fit=crop&w=520&q=80',
            notes: 'Perlu isolasi area sebelum aktivitas lanjut.'
          },
          {
            title: 'Kabel melintang di akses pejalan',
            area: 'Office Site',
            level: 'Rendah',
            color: '#22c55e',
            lat: 1.2175,
            lng: 117.2385,
            photo: 'https://images.unsplash.com/photo-1581092919535-7146ff1a590b?auto=format&fit=crop&w=520&q=80',
            notes: 'Rapikan jalur kabel dan pasang cover.'
          },
          {
            title: 'Debu tinggi di crusher',
            area: 'Crusher Area',
            level: 'Sedang',
            color: '#f97316',
            lat: 1.2071,
            lng: 117.2462,
            photo: 'https://images.unsplash.com/photo-1518709268805-4e9042af2176?auto=format&fit=crop&w=520&q=80',
            notes: 'Cek water spray dan penggunaan respirator.'
          },
          {
            title: 'Genangan dekat panel listrik',
            area: 'Fuel Station',
            level: 'Kritis',
            color: '#dc2626',
            lat: 1.2232,
            lng: 117.2268,
            photo: 'https://images.unsplash.com/photo-1581094480465-4e6c25fb4a52?auto=format&fit=crop&w=520&q=80',
            notes: 'Amankan panel dan lakukan draining area.'
          }
        ];

        const heatLayer = L.layerGroup().addTo(map);
        const markerLayer = L.layerGroup().addTo(map);

        hazardPoints.forEach((point) => {
          L.circle([point.lat, point.lng], {
            radius: point.level === 'Kritis' ? 460 : point.level === 'Tinggi' ? 360 : 270,
            color: point.color,
            weight: 0,
            fillColor: point.color,
            fillOpacity: point.level === 'Kritis' ? 0.22 : 0.16
          }).addTo(heatLayer);

          const marker = L.circleMarker([point.lat, point.lng], {
            radius: point.level === 'Kritis' ? 11 : 9,
            color: '#ffffff',
            weight: 2,
            fillColor: point.color,
            fillOpacity: 0.95
          }).addTo(markerLayer);

          marker.bindPopup(`
            <div class="hazard-popup">
              <img src="${point.photo}" />
              <span class="badge" style="background:${point.color}">${point.level}</span>
              <h3>${point.title}</h3>
              <p><strong>Area:</strong> ${point.area}</p>
              <p>${point.notes}</p>
            </div>
          `);
        });

        const legend = L.control({ position: 'bottomleft' });
        legend.onAdd = function () {
          const div = L.DomUtil.create('div', 'legend');
          div.innerHTML = `
            <strong>Level Hazard</strong>
            <div class="legend-row"><span class="dot" style="background:#22c55e"></span>Rendah</div>
            <div class="legend-row"><span class="dot" style="background:#f59e0b"></span>Sedang</div>
            <div class="legend-row"><span class="dot" style="background:#ef4444"></span>Tinggi</div>
            <div class="legend-row"><span class="dot" style="background:#b91c1c"></span>Kritis</div>
          `;
          return div;
        };
        legend.addTo(map);

        setTimeout(() => map.invalidateSize(), 250);
      </script>
    </body>
    </html>
    ''';
  }
}
