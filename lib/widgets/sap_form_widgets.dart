import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'snackbar_msg.dart';

class SapFormIntroCard extends StatelessWidget {
  const SapFormIntroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, .24)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .18),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SapFormSectionTitle extends StatelessWidget {
  const SapFormSectionTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = const Color(0xFF2563EB),
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6, bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> fillGpsCoordinate(
  BuildContext context,
  TextEditingController controller,
  VoidCallback onChanged, {
  bool silent = false,
}) async {
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (!silent && context.mounted) {
        SnackBarMsg.danger(
          context,
          'Aktifkan izin lokasi untuk mengambil koordinat GPS.',
        );
      }
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    controller.text =
        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    onChanged();
    if (!silent && context.mounted) {
      SnackBarMsg.success(context, 'Koordinat GPS berhasil diambil.');
    }
  } catch (e) {
    if (!silent && context.mounted) {
      SnackBarMsg.danger(context, 'Gagal mengambil lokasi GPS.');
    }
  }
}

InputDecoration gpsInputDecoration({
  required BuildContext context,
  required VoidCallback onPressed,
  Color iconColor = const Color(0xFF4F46E5),
}) {
  return InputDecoration(
    hintText: 'Klik ikon lokasi untuk ambil koordinat GPS otomatis',
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Icon(
        Icons.location_on,
        size: 24,
        color: iconColor,
      ),
    ),
    suffixIcon: IconButton(
      tooltip: 'Ambil Lokasi Aktual GPS',
      icon: const Icon(Icons.my_location_rounded),
      color: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
    ),
  );
}
