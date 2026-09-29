import 'package:flutter/material.dart';

import '../../widgets/top_bar.dart';

class AchievementSapPage extends StatelessWidget {
  const AchievementSapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MockScaffold(
      title: 'Pencapaian SAP',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroMetricCard(
            title: 'Pencapaian Individual',
            value: '112%',
            subtitle: 'Aktual 28 dari target 25 SAP bulan ini',
            color: Color(0xFF2563EB),
            icon: Icons.track_changes_rounded,
          ),
          SizedBox(height: 14),
          _SectionTitle('Aktual vs Target'),
          _ProgressMetric(label: 'Hazard Report', actual: 9, target: 8),
          _ProgressMetric(label: 'Observation', actual: 7, target: 6),
          _ProgressMetric(label: 'Safety Talk', actual: 5, target: 5),
          _ProgressMetric(label: 'Coaching', actual: 4, target: 3),
          _ProgressMetric(label: 'Inspection', actual: 3, target: 3),
          SizedBox(height: 18),
          _SectionTitle('Departemen'),
          _DepartmentCard(
              name: 'Digital Product Development', score: '104%', rank: '#2'),
          _DepartmentCard(name: 'Operation', score: '97%', rank: '#5'),
          _DepartmentCard(name: 'Plant', score: '91%', rank: '#7'),
        ],
      ),
    );
  }
}

class SapLeaguePage extends StatelessWidget {
  const SapLeaguePage({super.key});

  static const _rows = [
    ('1', 'A. Pratama', 'Operation', '1,240', '+12%'),
    ('2', 'Muhammad Alfian', 'DPD', '1,180', '+9%'),
    ('3', 'R. Wijaya', 'Plant', '1,095', '+7%'),
    ('4', 'D. Saputra', 'HSE', '1,040', '+5%'),
    ('5', 'N. Ananda', 'Mining', '980', '+3%'),
  ];

  @override
  Widget build(BuildContext context) {
    return _MockScaffold(
      title: 'Klasemen League SAP',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroMetricCard(
            title: 'SAP League',
            value: '#2',
            subtitle: 'Posisi anda bulan ini dari 128 peserta',
            color: Color(0xFFF59E0B),
            icon: Icons.emoji_events_rounded,
          ),
          const SizedBox(height: 14),
          const _SectionTitle('Leaderboard'),
          ..._rows.map((row) {
            return _LeagueTile(
              rank: row.$1,
              name: row.$2,
              dept: row.$3,
              point: row.$4,
              trend: row.$5,
            );
          }),
        ],
      ),
    );
  }
}

class IncidentInformationPage extends StatelessWidget {
  const IncidentInformationPage({super.key});

  static const _incidents = [
    IncidentArticle(
      imageUrl:
          'https://images.unsplash.com/photo-1503387762-592deb58ef4e?auto=format&fit=crop&w=900&q=80',
      category: 'High Potential Incident',
      title: 'Material loose ditemukan di hauling road KM 4',
      caption:
          'Tim operasi memasang rambu sementara dan melakukan pembersihan jalur. Tidak ada korban dalam kejadian ini.',
      date: '29 Sep 2026',
      location: 'Hauling Road KM 4',
      reporter: 'Operation Team',
      severity: 'High Potential',
      body: [
        'Pada pemeriksaan awal shift pagi, tim operasi menemukan material loose di sisi kiri hauling road KM 4. Kondisi tersebut berpotensi mengenai unit yang melintas apabila terkena getaran atau hujan intensitas tinggi.',
        'Area kemudian diamankan menggunakan traffic cone dan rambu sementara. Dispatcher mengalihkan lajur unit berat ke sisi aman sampai proses pembersihan dan pemeriksaan slope selesai dilakukan.',
        'Tindak lanjut yang direkomendasikan adalah inspeksi ulang setelah hujan, penambahan patrol road maintenance pada jam kritis, dan briefing kepada operator terkait pelaporan dini kondisi jalan tidak normal.',
      ],
    ),
    IncidentArticle(
      imageUrl:
          'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=900&q=80',
      category: 'Property Damage',
      title: 'Kontak ringan unit LV dengan pembatas area workshop',
      caption:
          'Investigasi awal menunjukkan blind spot saat manuver mundur. Refreshment defensive driving dijadwalkan pekan ini.',
      date: '28 Sep 2026',
      location: 'Workshop Light Vehicle',
      reporter: 'Plant Department',
      severity: 'Medium',
      body: [
        'Satu unit light vehicle mengalami kontak ringan dengan pembatas area workshop saat melakukan manuver mundur. Tidak terdapat cedera personel, namun terdapat kerusakan minor pada bumper belakang dan pembatas portable.',
        'Hasil review awal menunjukkan spotter belum berada pada posisi optimal dan driver tidak melakukan stop-look-wave secara lengkap sebelum kendaraan bergerak mundur.',
        'Action sementara meliputi pemasangan marka parkir tambahan, refreshment defensive driving, dan penegasan kembali penggunaan spotter pada area padat aktivitas.',
      ],
    ),
    IncidentArticle(
      imageUrl:
          'https://images.unsplash.com/photo-1590496793929-36417d3117de?auto=format&fit=crop&w=900&q=80',
      category: 'Safety Alert',
      title: 'Debu meningkat pada area crusher saat shift siang',
      caption:
          'Pengendalian sementara dilakukan melalui water spray tambahan dan inspeksi ulang penggunaan respirator.',
      date: '27 Sep 2026',
      location: 'Crusher Area',
      reporter: 'HSE Patrol',
      severity: 'Safety Alert',
      body: [
        'Tim HSE mencatat peningkatan paparan debu pada area crusher ketika aktivitas dumping meningkat pada shift siang. Visibility masih dalam batas operasi, namun beberapa pekerja terlihat perlu menyesuaikan respirator.',
        'Supervisor area mengaktifkan water spray tambahan dan mengatur jeda dumping agar debu tidak terkonsentrasi di satu titik. Pemeriksaan singkat dilakukan pada respirator pekerja dan kondisi filter.',
        'Rekomendasi lanjutan adalah verifikasi efektivitas water spray, inspeksi nozzle, dan komunikasi rutin kepada pekerja mengenai penggunaan respirator pada kondisi berdebu.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _MockScaffold(
      title: 'Informasi Insiden',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Berita Insiden Terbaru'),
          ..._incidents.map((incident) => _NewsCard(article: incident)),
        ],
      ),
    );
  }
}

class IncidentArticleDetailPage extends StatelessWidget {
  const IncidentArticleDetailPage({required this.article, super.key});

  final IncidentArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'Informasi Insiden'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IncidentImage(
              imageUrl: article.imageUrl,
              height: 240,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(label: article.category, icon: Icons.article),
                      _InfoChip(label: article.date, icon: Icons.event),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    article.caption,
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SurfaceCard(
                    child: Column(
                      children: [
                        _ArticleMetaRow(
                          icon: Icons.place_rounded,
                          label: 'Lokasi',
                          value: article.location,
                        ),
                        const Divider(height: 18),
                        _ArticleMetaRow(
                          icon: Icons.person_rounded,
                          label: 'Pelapor',
                          value: article.reporter,
                        ),
                        const Divider(height: 18),
                        _ArticleMetaRow(
                          icon: Icons.warning_amber_rounded,
                          label: 'Klasifikasi',
                          value: article.severity,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _SectionTitle('Kronologi & Tindak Lanjut'),
                  ...article.body.map(
                    (paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        paragraph,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncidentArticle {
  const IncidentArticle({
    required this.imageUrl,
    required this.category,
    required this.title,
    required this.caption,
    required this.date,
    required this.location,
    required this.reporter,
    required this.severity,
    required this.body,
  });

  final String imageUrl;
  final String category;
  final String title;
  final String caption;
  final String date;
  final String location;
  final String reporter;
  final String severity;
  final List<String> body;
}

class WorkRosterPage extends StatefulWidget {
  const WorkRosterPage({super.key});

  @override
  State<WorkRosterPage> createState() => _WorkRosterPageState();
}

class _WorkRosterPageState extends State<WorkRosterPage> {
  bool _reminder = true;
  String _pattern = '5-2';
  String _shift = 'Day Shift';

  @override
  Widget build(BuildContext context) {
    return _MockScaffold(
      title: 'Roster Kerja',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroMetricCard(
            title: 'Roster Aktif',
            value: 'Day',
            subtitle: 'Periode 29 Sep - 03 Okt 2026',
            color: Color(0xFF0F766E),
            icon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: 14),
          const _SectionTitle('Pengaturan Pribadi'),
          _SettingCard(
            title: 'Pola roster',
            subtitle: _pattern,
            icon: Icons.date_range_rounded,
            trailing: DropdownButton<String>(
              value: _pattern,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: '5-2', child: Text('5-2')),
                DropdownMenuItem(value: '6-1', child: Text('6-1')),
                DropdownMenuItem(value: '14-7', child: Text('14-7')),
              ],
              onChanged: (value) =>
                  setState(() => _pattern = value ?? _pattern),
            ),
          ),
          _SettingCard(
            title: 'Shift utama',
            subtitle: _shift,
            icon: Icons.schedule_rounded,
            trailing: DropdownButton<String>(
              value: _shift,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'Day Shift', child: Text('Day')),
                DropdownMenuItem(value: 'Night Shift', child: Text('Night')),
              ],
              onChanged: (value) => setState(() => _shift = value ?? _shift),
            ),
          ),
          _SettingCard(
            title: 'Reminder sebelum shift',
            subtitle: 'Notifikasi 60 menit sebelum jadwal',
            icon: Icons.notifications_active_rounded,
            trailing: Switch(
              value: _reminder,
              onChanged: (value) => setState(() => _reminder = value),
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Jadwal Minggu Ini'),
          const _ScheduleChip(day: 'Sen', value: 'Day'),
          const _ScheduleChip(day: 'Sel', value: 'Day'),
          const _ScheduleChip(day: 'Rab', value: 'Day'),
          const _ScheduleChip(day: 'Kam', value: 'Off'),
          const _ScheduleChip(day: 'Jum', value: 'Night'),
        ],
      ),
    );
  }
}

class SapQualityPage extends StatelessWidget {
  const SapQualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MockScaffold(
      title: 'Kualitas SAP',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroMetricCard(
            title: 'Quality Score',
            value: '86',
            subtitle: 'Baik - 18 data berkualitas dari 21 input',
            color: Color(0xFF16A34A),
            icon: Icons.verified_rounded,
          ),
          SizedBox(height: 14),
          _SectionTitle('Kualitas Input'),
          _QualityTile(
              label: 'Baik', value: 18, total: 21, color: Color(0xFF16A34A)),
          _QualityTile(
              label: 'Memenuhi Target',
              value: 2,
              total: 21,
              color: Color(0xFFF59E0B)),
          _QualityTile(
              label: 'Perlu Perbaikan',
              value: 1,
              total: 21,
              color: Color(0xFFEF4444)),
          SizedBox(height: 16),
          _SectionTitle('Catatan Evaluasi'),
          _InsightCard(
              text:
                  'Foto evidence sudah konsisten dan remark mudah dipahami. Tingkatkan detail lokasi pada temuan area workshop.'),
        ],
      ),
    );
  }
}

class ActionTrackerPage extends StatelessWidget {
  const ActionTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MockScaffold(
      title: 'Action Tracker',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroMetricCard(
            title: 'Progress Action SAP',
            value: '72%',
            subtitle: '8 closed, 3 on progress, 1 overdue',
            color: Color(0xFF7C3AED),
            icon: Icons.assignment_turned_in_rounded,
          ),
          SizedBox(height: 14),
          _SectionTitle('Daftar Action'),
          _ActionTimelineTile(
              title: 'Pasang barricade area pit selatan',
              owner: 'Operation',
              status: 'On Progress',
              progress: .65,
              color: Color(0xFF2563EB)),
          _ActionTimelineTile(
              title: 'Housekeeping tumpahan oli workshop',
              owner: 'Plant',
              status: 'Closed',
              progress: 1,
              color: Color(0xFF16A34A)),
          _ActionTimelineTile(
              title: 'Refreshment defensive driving',
              owner: 'HSE',
              status: 'Overdue',
              progress: .35,
              color: Color(0xFFEF4444)),
          _ActionTimelineTile(
              title: 'Perbaikan signage hauling KM 4',
              owner: 'Mining',
              status: 'Review',
              progress: .85,
              color: Color(0xFFF59E0B)),
        ],
      ),
    );
  }
}

class DriverPerformanceAssessmentPage extends StatelessWidget {
  const DriverPerformanceAssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MockScaffold(
      title: 'DPA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroMetricCard(
            title: 'Driver Performance Assessment',
            value: 'A-',
            subtitle: 'Assessment driver roster/cuti bulan berjalan',
            color: Color(0xFF0284C7),
            icon: Icons.drive_eta_rounded,
          ),
          SizedBox(height: 14),
          _SectionTitle('Assessment Terbaru'),
          _DriverTile(
              name: 'Irfan Setiawan',
              unit: 'LV-023',
              score: '92',
              status: 'Excellent'),
          _DriverTile(
              name: 'Rudi Hartono',
              unit: 'BUS-017',
              score: '87',
              status: 'Good'),
          _DriverTile(
              name: 'Agus Firmansyah',
              unit: 'LV-041',
              score: '78',
              status: 'Coaching Required'),
          SizedBox(height: 16),
          _SectionTitle('Parameter Penilaian'),
          _QualityTile(
              label: 'Defensive driving',
              value: 92,
              total: 100,
              color: Color(0xFF16A34A)),
          _QualityTile(
              label: 'Punctuality roster pickup',
              value: 88,
              total: 100,
              color: Color(0xFF2563EB)),
          _QualityTile(
              label: 'Vehicle readiness',
              value: 81,
              total: 100,
              color: Color(0xFFF59E0B)),
          _QualityTile(
              label: 'Passenger feedback',
              value: 90,
              total: 100,
              color: Color(0xFF16A34A)),
        ],
      ),
    );
  }
}

class _MockScaffold extends StatelessWidget {
  const _MockScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

class _HeroMetricCard extends StatelessWidget {
  const _HeroMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 10),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
          Icon(icon, color: Colors.white, size: 52),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric(
      {required this.label, required this.actual, required this.target});

  final String label;
  final int actual;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (actual / target).clamp(0.0, 1.0);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('$actual / $target',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard(
      {required this.name, required this.score, required this.rank});

  final String name;
  final String score;
  final String rank;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.indigo.shade50,
              child: Text(rank,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(score,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: Colors.indigo)),
        ],
      ),
    );
  }
}

class _LeagueTile extends StatelessWidget {
  const _LeagueTile(
      {required this.rank,
      required this.name,
      required this.dept,
      required this.point,
      required this.trend});

  final String rank;
  final String name;
  final String dept;
  final String point;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
            backgroundColor: Colors.amber.shade100,
            child: Text(rank,
                style: const TextStyle(fontWeight: FontWeight.w800))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(dept),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(point, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(trend,
                style: const TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article});

  final IncidentArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncidentArticleDetailPage(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IncidentImage(imageUrl: article.imageUrl, height: 150),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${article.category}  |  ${article.date}',
                      style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(article.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(article.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.black87, height: 1.35)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Baca detail',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentImage extends StatelessWidget {
  const _IncidentImage({
    required this.imageUrl,
    required this.height,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(18)),
  });

  final String imageUrl;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: double.infinity,
            color: Colors.indigo.shade50,
            child: Icon(
              Icons.image_not_supported_rounded,
              color: Colors.indigo.shade200,
              size: 46,
            ),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16, color: Colors.indigo),
      label: Text(label),
      backgroundColor: Colors.indigo.shade50,
      side: BorderSide(color: Colors.indigo.shade100),
    );
  }
}

class _ArticleMetaRow extends StatelessWidget {
  const _ArticleMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.indigo, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.trailing});

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ScheduleChip extends StatelessWidget {
  const _ScheduleChip({required this.day, required this.value});

  final String day;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w700)),
          Chip(label: Text(value), visualDensity: VisualDensity.compact),
        ],
      ),
    );
  }
}

class _QualityTile extends StatelessWidget {
  const _QualityTile(
      {required this.label,
      required this.value,
      required this.total,
      required this.color});

  final String label;
  final int value;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = (value / total).clamp(0.0, 1.0);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('$value/$total',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _ActionTimelineTile extends StatelessWidget {
  const _ActionTimelineTile({
    required this.title,
    required this.owner,
    required this.status,
    required this.progress,
    required this.color,
  });

  final String title;
  final String owner;
  final String status;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              Chip(
                  label: Text(status),
                  backgroundColor: color.withValues(alpha: .12),
                  labelStyle:
                      TextStyle(color: color, fontWeight: FontWeight.w700)),
            ],
          ),
          Text(owner,
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}

class _DriverTile extends StatelessWidget {
  const _DriverTile(
      {required this.name,
      required this.unit,
      required this.score,
      required this.status});

  final String name;
  final String unit;
  final String score;
  final String status;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person, color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('$unit  |  $status',
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          Text(score,
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
    );
  }
}
