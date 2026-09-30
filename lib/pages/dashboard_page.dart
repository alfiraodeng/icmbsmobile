import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/link_model.dart';
import '../services/preference.dart';
import '../utils/links.dart';
import '../utils/routers.dart';
import 'menu/extra_page.dart';
import 'menu/ohs_page.dart';
import 'menu/sap_page.dart';

class _HomeModuleCard extends StatelessWidget {
  const _HomeModuleCard({
    required this.title,
    required this.imagePath,
    required this.labelColor,
    required this.onTap,
    this.iconHeight = 68,
  });

  final String title;
  final String imagePath;
  final Color labelColor;
  final VoidCallback onTap;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 126,
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD9E1F2)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: .06),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    imagePath,
                    height: iconHeight,
                    width: 82,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 32,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: labelColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _injectCurrentPosition(WebViewController controller) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    await controller.runJavaScript(
      'window.setUserLocation(${position.latitude}, ${position.longitude}, ${position.accuracy});',
    );
  } catch (error) {
    debugPrint('Gagal menampilkan posisi pengguna pada heatmap: $error');
  }
}

class _FullscreenHazardMapPage extends StatefulWidget {
  const _FullscreenHazardMapPage({required this.html});

  final String html;

  @override
  State<_FullscreenHazardMapPage> createState() =>
      _FullscreenHazardMapPageState();
}

class _FullscreenHazardMapPageState extends State<_FullscreenHazardMapPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _injectCurrentPosition(_controller),
        ),
      )
      ..loadHtmlString(widget.html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: WebViewWidget(
                controller: _controller,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FilledButton.tonalIcon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.fullscreen_exit_rounded),
                    label: const Text('Perkecil'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1D4ED8),
                      elevation: 5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _injectCurrentPosition(_hazardMapCtrl),
        ),
      )
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
        preferredSize: const Size.fromHeight(138),
        child: AppBar(
          toolbarHeight: 138,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/home-indexsafe.png',
                  height: 42,
                  width: 46,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: Stack(
                    children: [
                      Visibility(
                        visible: (_searchText == ''),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child:
                              Text('Search...', style: TextStyle(fontSize: 18)),
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
                              .where((e) =>
                                  e.title.replaceAll('\n', ' ') == selection)
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
                children: [
                  Expanded(
                    child: _HomeModuleCard(
                      title: 'SAP',
                      imagePath: 'assets/images/home-sap.png',
                      labelColor: const Color(0xFF174B83),
                      iconHeight: 70,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const SapPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HomeModuleCard(
                      title: 'OHS',
                      imagePath: 'assets/images/home-ohs.png',
                      labelColor: const Color(0xFF0F9F8F),
                      iconHeight: 72,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const OhsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _HomeModuleCard(
                      title: 'PERFORMANCE\nHUB',
                      imagePath: 'assets/images/home-performance-hub.png',
                      labelColor: const Color(0xFFF08A00),
                      iconHeight: 66,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (context) => const ExtraPage(),
                          ),
                        );
                      },
                    ),
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
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: WebViewWidget(
                              controller: _hazardMapCtrl,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                            ),
                          ),
                          Positioned(
                            top: 112,
                            right: 12,
                            child: Material(
                              color: Colors.white,
                              elevation: 5,
                              borderRadius: BorderRadius.circular(11),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) =>
                                          _FullscreenHazardMapPage(
                                        html: _hazardMapHtml(),
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(11),
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(
                                    Icons.fullscreen_rounded,
                                    color: Color(0xFF1D4ED8),
                                    size: 27,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
        .leaflet-control-zoom a {
          width: 34px !important;
          height: 34px !important;
          line-height: 32px !important;
          font-size: 19px !important;
        }
        .leaflet-control-layers-toggle {
          width: 38px !important;
          height: 38px !important;
          background-size: 22px 22px !important;
        }
        .leaflet-left .leaflet-control {
          margin-left: 12px !important;
        }
        .leaflet-right .leaflet-control {
          margin-right: 12px !important;
        }
        .leaflet-top .leaflet-control {
          margin-top: 12px !important;
        }
        .leaflet-popup-content-wrapper {
          border-radius: 14px;
          box-shadow: 0 12px 30px rgba(15, 23, 42, .22);
        }
        .leaflet-popup {
          transition: opacity .14s ease-out;
        }
        .hazard-popup {
          width: 190px;
        }
        .hazard-popup img {
          width: 190px;
          height: 104px;
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
        .user-location-arrow {
          width: 34px;
          height: 34px;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 50%;
          background: #ffffff;
          border: 2px solid #2563eb;
          box-shadow: 0 0 0 7px rgba(37, 99, 235, .18), 0 4px 12px rgba(15, 23, 42, .28);
          position: relative;
        }
        .user-location-arrow svg {
          width: 24px;
          height: 24px;
          fill: #2563eb;
          transform: rotate(18deg);
        }
        .user-location-arrow::after {
          content: '';
          position: absolute; 
          inset: -9px;
          border: 2px solid rgba(37, 99, 235, .45);
          border-radius: 50%;
          animation: userPulse 1.8s ease-out infinite;
        }
        @keyframes userPulse {
          0% { transform: scale(.65); opacity: 1; }
          100% { transform: scale(1.7); opacity: 0; }
        }
        .locate-me-button {
          width: 34px;
          height: 34px;
          display: flex;
          align-items: center;
          justify-content: center;
          background: #ffffff;
          color: #2563eb;
          font-size: 22px;
          font-weight: 800;
          text-decoration: none;
          border-radius: 10px;
          box-shadow: 0 8px 20px rgba(15, 23, 42, .16);
        }
        .locate-me-button:active {
          background: #eff6ff;
        }
      </style>
    </head>
    <body>
      <div id="map"></div>
      <script>
        const street = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          maxZoom: 19,
          keepBuffer: 4,
          updateWhenIdle: false,
          attribution: '&copy; OpenStreetMap'
        });

        const satellite = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
          maxZoom: 19,
          keepBuffer: 4,
          updateWhenIdle: false,
          attribution: 'Tiles &copy; Esri'
        });

        const map = L.map('map', {
          center: [1.2057, 117.2247],
          zoom: 13,
          layers: [satellite],
          preferCanvas: true,
          zoomControl: true,
          dragging: true,
          scrollWheelZoom: true,
          doubleClickZoom: true,
          touchZoom: true,
          closePopupOnClick: true,
          zoomAnimation: true,
          fadeAnimation: true,
          markerZoomAnimation: true,
          inertia: true,
          inertiaDeceleration: 2600,
          easeLinearity: .22,
          zoomSnap: .5,
          zoomDelta: .5,
          wheelPxPerZoomLevel: 90
        });

        map.on('preclick', function() {
          map.closePopup();
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
            status: 'On Progress',
            statusColor: '#f59e0b',
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
            status: 'Open',
            statusColor: '#ef4444',
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
            status: 'Open',
            statusColor: '#ef4444',
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
            status: 'Closed',
            statusColor: '#16a34a',
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
            status: 'On Progress',
            statusColor: '#f59e0b',
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
            status: 'Open',
            statusColor: '#ef4444',
            lat: 1.2232,
            lng: 117.2268,
            photo: 'https://images.unsplash.com/photo-1581094480465-4e6c25fb4a52?auto=format&fit=crop&w=520&q=80',
            notes: 'Amankan panel dan lakukan draining area.'
          }
        ];

        const heatLayer = L.layerGroup().addTo(map);
        const markerLayer = L.layerGroup().addTo(map);
        let userMarker = null;
        let userAccuracyCircle = null;
        let userCoordinates = null;

        window.setUserLocation = function(lat, lng, accuracy) {
          userCoordinates = [lat, lng];
          if (userMarker) map.removeLayer(userMarker);
          if (userAccuracyCircle) map.removeLayer(userAccuracyCircle);

          const userIcon = L.divIcon({
            className: '',
            html: '<div class="user-location-arrow"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2 4.5 20.29l.71.71L12 18l6.79 3 .71-.71L12 2z"/></svg></div>',
            iconSize: [38, 38],
            iconAnchor: [19, 19]
          });
          userAccuracyCircle = L.circle(userCoordinates, {
            radius: Math.max(accuracy || 10, 10),
            color: '#2563eb',
            weight: 1,
            fillColor: '#60a5fa',
            fillOpacity: .12
          }).addTo(map);
          userMarker = L.marker(userCoordinates, {
            icon: userIcon,
            zIndexOffset: 1000
          }).addTo(map);
          userMarker.bindPopup(`
            <div style="min-width:170px">
              <strong style="font-size:14px;color:#1d4ed8">Posisi Saya</strong>
              <p style="margin:7px 0 2px;font-size:12px;color:#4b5563">Lokasi perangkat saat ini</p>
              <p style="margin:2px 0;font-size:11px;color:#64748b">${lat.toFixed(6)}, ${lng.toFixed(6)}</p>
              <p style="margin:2px 0;font-size:11px;color:#64748b">Akurasi ±${Math.round(accuracy || 0)} meter</p>
            </div>
          `);
          map.flyTo(userCoordinates, 15, { animate: true, duration: .6 });
          setTimeout(() => userMarker.openPopup(), 650);
        };

        const LocateMeControl = L.Control.extend({
          options: { position: 'topright' },
          onAdd: function() {
            const button = L.DomUtil.create('a', 'locate-me-button');
            button.href = '#';
            button.title = 'Lihat Posisi Saya';
            button.innerHTML = '⌖';
            L.DomEvent.disableClickPropagation(button);
            L.DomEvent.on(button, 'click', function(event) {
              L.DomEvent.preventDefault(event);
              if (userCoordinates) {
                map.flyTo(userCoordinates, 16, { animate: true, duration: .55 });
                if (userMarker) setTimeout(() => userMarker.openPopup(), 600);
              }
            });
            return button;
          }
        });
        map.addControl(new LocateMeControl());

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
              <span class="badge" style="background:${point.statusColor};margin-left:5px">${point.status}</span>
              <h3>${point.title}</h3>
              <p><strong>Area:</strong> ${point.area}</p>
              <p><strong>Status Hazard:</strong> ${point.status}</p>
              <p>${point.notes}</p>
            </div>
          `, {
            maxWidth: 210,
            autoPan: true,
            autoPanPaddingTopLeft: [18, 90],
            autoPanPaddingBottomRight: [18, 28]
          });
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
