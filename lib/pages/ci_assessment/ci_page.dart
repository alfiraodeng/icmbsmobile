import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../widgets/top_bar.dart';
import 'ci_form_page.dart';
import 'ci_model.dart';

const _ciNavy = Color(0xFF123B63);
const _ciBg = Color(0xFFF4F7FA);

class CiAssessmentPage extends StatefulWidget {
  const CiAssessmentPage({super.key});
  @override
  State<CiAssessmentPage> createState() => _CiAssessmentPageState();
}

class _CiAssessmentPageState extends State<CiAssessmentPage> {
  late Future<List<CiAssessment>> _future;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = CiStorage.load();
  Future<void> _open(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _ciBg,
        appBar: const TopBar(title: 'CI Digital Technical Assessment'),
        body: FutureBuilder<List<CiAssessment>>(
            future: _future,
            builder: (_, snapshot) {
              final data = snapshot.data ?? const <CiAssessment>[];
              return RefreshIndicator(
                  onRefresh: () async {
                    setState(_reload);
                    await _future;
                  },
                  child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                      children: [
                        _hero(data),
                        const SizedBox(height: 20),
                        const Text('Pilih Jenis Assessment',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF172033))),
                        const SizedBox(height: 10),
                        _typeCard(
                            'FCI',
                            'Front Condition Index',
                            'Kesiapan dan kondisi area loading front.',
                            Icons.landscape_rounded,
                            const Color(0xFF0284C7)),
                        _typeCard(
                            'RCI',
                            'Road Condition Index',
                            'Kondisi dan kelayakan ruas jalan operasional.',
                            Icons.add_road_rounded,
                            const Color(0xFFF59E0B)),
                        _typeCard(
                            'DCI',
                            'Disposal Condition Index',
                            'Kesiapan dan kondisi area disposal/dumping.',
                            Icons.terrain_rounded,
                            const Color(0xFF7C3AED)),
                        const SizedBox(height: 18),
                        Row(children: [
                          const Expanded(
                              child: Text('Assessment Terbaru',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900))),
                          if (data.isNotEmpty)
                            TextButton(
                                onPressed: () => _open(CiHistoryPage(data)),
                                child: const Text('Lihat Semua'))
                        ]),
                        if (data.isEmpty)
                          _empty()
                        else
                          ...data.take(4).map((e) => _historyTile(e)),
                      ]));
            }),
      );

  Widget _hero(List<CiAssessment> data) {
    final open = data.where((e) => e.status != 'Closed').length;
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_ciNavy, Color(0xFF087A88)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33123B63),
                  blurRadius: 18,
                  offset: Offset(0, 8))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.analytics_rounded, color: Colors.white)),
            SizedBox(width: 10),
            Expanded(
                child: Text('3CI Digital Assessment',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)))
          ]),
          const SizedBox(height: 9),
          const Text(
              'Keputusan operasional berbasis kondisi aktual, kontrol kritis, dan standar teknis aktif.',
              style: TextStyle(color: Color(0xFFD9F4F5), height: 1.4)),
          const SizedBox(height: 18),
          Row(children: [
            _metric('${data.length}', 'Total'),
            _metric('$open', 'Open'),
            _metric(
                '${data.where((e) => e.criticalOverride).length}', 'Critical')
          ]),
        ]));
  }

  Widget _metric(String value, String label) => Expanded(
      child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(13)),
          child: Column(children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900)),
            Text(label,
                style: const TextStyle(color: Color(0xFFD9F4F5), fontSize: 11))
          ])));
  Widget _typeCard(String code, String title, String subtitle, IconData icon,
          Color color) =>
      Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          color: Colors.white,
          child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _open(CiFormPage(code)),
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(children: [
                    Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(icon, color: color, size: 28)),
                    const SizedBox(width: 13),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(children: [
                            Text(code,
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.w900)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)))
                          ]),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                  height: 1.3))
                        ])),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.blueGrey)
                  ]))));
  Widget _historyTile(CiAssessment item) {
    final color = _resultColor(item);
    return Card(
        margin: const EdgeInsets.only(bottom: 9),
        elevation: 0,
        child: ListTile(
            onTap: () => _open(CiDetailPage(item)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: .1),
                child: Text(item.type,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w900))),
            title: Text(item.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(
                '${DateFormat('dd MMM yyyy, HH:mm').format(item.assessedAt)} • ${item.operationalStatus}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            trailing:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(item.index.toStringAsFixed(0),
                  style: TextStyle(
                      color: color, fontSize: 18, fontWeight: FontWeight.w900)),
              Text(item.band,
                  style: TextStyle(
                      color: color, fontSize: 8, fontWeight: FontWeight.w800))
            ])));
  }

  Widget _empty() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const Column(children: [
        Icon(Icons.assignment_outlined, size: 36, color: Colors.blueGrey),
        SizedBox(height: 8),
        Text('Belum ada assessment',
            style: TextStyle(fontWeight: FontWeight.w800)),
        SizedBox(height: 3),
        Text('Pilih FCI, RCI, atau DCI untuk memulai.',
            style: TextStyle(color: Colors.blueGrey))
      ]));
}

class CiHistoryPage extends StatelessWidget {
  const CiHistoryPage(this.items, {super.key});
  final List<CiAssessment> items;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: _ciBg,
        appBar: const TopBar(title: 'Riwayat 3CI', back: 2),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final item = items[i];
            final color = _resultColor(item);
            return Card(
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CiDetailPage(item)),
                ),
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: .1),
                  child: Text(
                    item.type,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                title: Text(
                  item.location,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${DateFormat('dd MMM yyyy, HH:mm').format(item.assessedAt)}\n${item.operationalStatus} • ${item.status}',
                ),
                trailing: Text(
                  item.index.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          },
        ),
      );
}

class CiDetailPage extends StatefulWidget {
  const CiDetailPage(this.assessment, {super.key});
  final CiAssessment assessment;
  @override
  State<CiDetailPage> createState() => _CiDetailPageState();
}

class _CiDetailPageState extends State<CiDetailPage> {
  late CiAssessment _item = widget.assessment;
  Future<void> _verify() async {
    final notes = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Verifikasi / Reinspection',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 7),
                  const Text(
                      'Catat hasil pemeriksaan ulang setelah action diselesaikan.'),
                  const SizedBox(height: 14),
                  TextField(
                      controller: notes,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          hintText:
                              'Hasil verifikasi dan bukti efektivitas...')),
                  const SizedBox(height: 12),
                  SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                          onPressed: () => Navigator.pop(context, true),
                          icon: const Icon(Icons.verified_rounded),
                          label: const Text('Tandai Terverifikasi')))
                ])));
    if (ok != true || notes.text.trim().isEmpty) return;
    final updated = _item.copyWith(
        status: 'Closed',
        verificationNotes: notes.text.trim(),
        verifiedAt: DateTime.now());
    await CiStorage.save(updated);
    if (mounted) setState(() => _item = updated);
  }

  @override
  Widget build(BuildContext context) {
    final color = _resultColor(_item);
    final params = CiCatalog.forType(_item.type);
    return Scaffold(
        backgroundColor: _ciBg,
        appBar: TopBar(title: 'Hasil ${_item.type}', back: 2),
        body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
            children: [
              Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(22)),
                  child: Row(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_item.band,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(_item.operationalStatus,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                          if (_item.criticalOverride)
                            const Text('Critical override',
                                style: TextStyle(color: Colors.white70))
                        ]),
                    const Spacer(),
                    Text(_item.index.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900))
                  ])),
              const SizedBox(height: 13),
              _section('Informasi Assessment', [
                _row('Nomor', _item.id),
                _row('Jenis', '${_item.type} — ${_typeLong(_item.type)}'),
                _row(
                    'Assessor', '${_item.assessorName} (${_item.assessorNik})'),
                _row('Waktu',
                    DateFormat('dd MMM yyyy, HH:mm').format(_item.assessedAt)),
                _row('Lokasi', '${_item.location}\n${_item.coordinate}'),
                _row('Area Owner', _item.areaOwner),
                _row('Konteks', _item.context),
                _row('Rule Set', _item.ruleVersion)
              ]),
              _section('Risiko & Action', [
                _row('Prioritas', _item.priority),
                _row('Risk Input',
                    'C${_item.consequence} × L${_item.likelihood} • ${_item.exposure}'),
                _row('Kontrol Sementara', _item.temporaryControls),
                _row('Corrective Action', _item.action),
                _row('PIC', _item.actionOwner),
                _row('Target', DateFormat('dd MMM yyyy').format(_item.dueDate)),
                _row('Validitas',
                    DateFormat('dd MMM yyyy').format(_item.validUntil)),
                _row('Status', _item.status),
                if (_item.verificationNotes.isNotEmpty)
                  _row('Hasil Verifikasi', _item.verificationNotes)
              ]),
              _section(
                  'Parameter Teknis',
                  _item.answers.map((a) {
                    final p = params.firstWhere((e) => e.id == a.parameterId);
                    return _row(
                        '${p.id} • ${p.title}',
                        a.score == null
                            ? 'N/A'
                            : '${a.score}/5${a.value.isNotEmpty && a.value != '__NA__' ? ' • ${a.value} ${a.unit}' : ''}${a.note.isNotEmpty ? '\n${a.note}' : ''}${a.criticalFailure ? '\nCRITICAL CONTROL FAILURE' : ''}');
                  }).toList()),
              if (_item.evidencePaths.isNotEmpty) ...[
                const Text('Bukti Foto',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                SizedBox(
                    height: 110,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _item.evidencePaths.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(File(_item.evidencePaths[i]),
                                width: 130, fit: BoxFit.cover))))
              ],
              const SizedBox(height: 18),
              FilledButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => CiPdfPage(_item))),
                  style: FilledButton.styleFrom(
                      backgroundColor: _ciNavy,
                      minimumSize: const Size.fromHeight(50)),
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Lihat Laporan PDF')),
              if (_item.status != 'Closed') ...[
                const SizedBox(height: 9),
                OutlinedButton.icon(
                    onPressed: _verify,
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50)),
                    icon: const Icon(Icons.verified_rounded),
                    label: const Text('Verifikasi / Reinspection'))
              ],
            ]));
  }
}

class CiPdfPage extends StatelessWidget {
  const CiPdfPage(this.item, {super.key});
  final CiAssessment item;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: TopBar(title: 'Laporan ${item.type}', back: 2),
      body: PdfPreview(
          build: _buildPdf,
          canChangePageFormat: false,
          canDebug: false,
          pdfFileName: '${item.id}.pdf'));

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final logoData =
        await rootBundle.load('assets/images/indexsafe-logo-text.png');
    final logo = pw.MemoryImage(logoData.buffer.asUint8List());
    final photos = <pw.MemoryImage>[];
    for (final path in item.evidencePaths) {
      if (File(path).existsSync()) {
        photos.add(pw.MemoryImage(await File(path).readAsBytes()));
      }
    }
    final params = CiCatalog.forType(item.type);
    const navy = PdfColor.fromInt(0xFF123B63),
        cyan = PdfColor.fromInt(0xFF0EA5A8),
        grey = PdfColor.fromInt(0xFF667085),
        line = PdfColor.fromInt(0xFFE2E8F0);
    final doc = pw.Document(
        title: 'Laporan ${item.type} ${item.id}',
        author: 'MBS SAP - System Integration Department PT INDEXIM COALINDO');
    doc.addPage(pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.fromLTRB(34, 28, 34, 34),
        header: (_) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: 115),
                  pw.Text(item.id,
                      style: const pw.TextStyle(color: grey, fontSize: 8))
                ])),
        footer: (c) => pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: line))),
            child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Developed & maintained by System Integration Department - PT INDEXIM COALINDO',
                      style: const pw.TextStyle(color: grey, fontSize: 7)),
                  pw.Text('${c.pageNumber}/${c.pagesCount}',
                      style: const pw.TextStyle(color: grey, fontSize: 8))
                ])),
        build: (_) => [
              pw.Center(
                  child: pw.Column(children: [
                pw.Text('${item.type} TECHNICAL ASSESSMENT',
                    style: pw.TextStyle(
                        color: navy,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(_typeLong(item.type),
                    style: const pw.TextStyle(color: grey, fontSize: 10))
              ])),
              pw.SizedBox(height: 14),
              pw.Container(
                  padding: const pw.EdgeInsets.all(14),
                  decoration: pw.BoxDecoration(
                      color: cyan.shade(.9),
                      borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(item.band,
                                  style: pw.TextStyle(
                                      color: navy,
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(item.operationalStatus,
                                  style: const pw.TextStyle(
                                      color: navy, fontSize: 10))
                            ]),
                        pw.Text(item.index.toStringAsFixed(1),
                            style: pw.TextStyle(
                                color: navy,
                                fontSize: 26,
                                fontWeight: pw.FontWeight.bold))
                      ])),
              pw.SizedBox(height: 12),
              _pdfSection('INFORMASI', [
                _pdfRow('Nomor', item.id),
                _pdfRow(
                    'Assessor', '${item.assessorName} (${item.assessorNik})'),
                _pdfRow('Tanggal',
                    DateFormat('dd MMMM yyyy, HH:mm').format(item.assessedAt)),
                _pdfRow('Lokasi / GPS', '${item.location}\n${item.coordinate}'),
                _pdfRow('Area Owner', item.areaOwner),
                _pdfRow('Konteks', item.context),
                _pdfRow('Rule Set', item.ruleVersion)
              ]),
              _pdfSection('KEPUTUSAN, RISIKO & ACTION', [
                _pdfRow('Critical Override',
                    item.criticalOverride ? 'YA' : 'Tidak'),
                _pdfRow('Prioritas', item.priority),
                _pdfRow('Risk Input',
                    'C${item.consequence} × L${item.likelihood} • ${item.exposure}'),
                _pdfRow('Kontrol Sementara', item.temporaryControls),
                _pdfRow('Corrective Action', item.action),
                _pdfRow('PIC / Target',
                    '${item.actionOwner} • ${DateFormat('dd MMM yyyy').format(item.dueDate)}'),
                _pdfRow('Berlaku Sampai',
                    DateFormat('dd MMM yyyy').format(item.validUntil)),
                if (item.verificationNotes.isNotEmpty)
                  _pdfRow('Verifikasi', item.verificationNotes)
              ]),
              pw.Text('HASIL PARAMETER TEKNIS',
                  style: pw.TextStyle(
                      color: navy,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Table(
                  border: pw.TableBorder.all(color: line),
                  columnWidths: const {
                    0: pw.FixedColumnWidth(30),
                    1: pw.FlexColumnWidth(3),
                    2: pw.FixedColumnWidth(34),
                    3: pw.FlexColumnWidth(2)
                  },
                  children: [
                    pw.TableRow(
                        decoration: const pw.BoxDecoration(
                            color: PdfColor.fromInt(0xFFEAF2F7)),
                        children: [
                          _cell('ID', bold: true),
                          _cell('Parameter', bold: true),
                          _cell('Skor', bold: true),
                          _cell('Hasil / Catatan', bold: true)
                        ]),
                    ...item.answers.map((a) {
                      final p = params.firstWhere((e) => e.id == a.parameterId);
                      return pw.TableRow(children: [
                        _cell(p.id),
                        _cell(p.title),
                        _cell(a.score?.toString() ?? 'N/A'),
                        _cell(
                            '${a.value == '__NA__' ? '' : a.value} ${a.unit}\n${a.note}${a.criticalFailure ? '\nCRITICAL FAILURE' : ''}')
                      ]);
                    })
                  ]),
              if (photos.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                pw.Text('BUKTI FOTO',
                    style: pw.TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: photos
                        .map((p) => pw.Container(
                            width: 150,
                            height: 105,
                            child: pw.Image(p, fit: pw.BoxFit.cover)))
                        .toList())
              ],
            ]));
    return doc.save();
  }
}

Color _resultColor(CiAssessment item) =>
    item.criticalOverride || item.index < 50
        ? const Color(0xFFDC2626)
        : item.index < 80
            ? const Color(0xFFF59E0B)
            : const Color(0xFF059669);
String _typeLong(String type) => switch (type) {
      'RCI' => 'Road Condition Index',
      'DCI' => 'Disposal Condition Index',
      _ => 'Front Condition Index'
    };
Widget _section(String title, List<Widget> rows) => Container(
    margin: const EdgeInsets.only(bottom: 13),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              color: _ciNavy, fontSize: 15, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      ...rows
    ]));
Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
          width: 112,
          child: Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey))),
      Expanded(
          child: Text(value.isEmpty ? '-' : value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, height: 1.35)))
    ]));
pw.Widget _pdfSection(String title, List<pw.Widget> rows) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE2E8F0)),
        borderRadius: pw.BorderRadius.circular(6)),
    child:
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title,
          style: pw.TextStyle(
              color: const PdfColor.fromInt(0xFF123B63),
              fontSize: 10,
              fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 5),
      ...rows
    ]));
pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.SizedBox(
          width: 95,
          child: pw.Text(label,
              style: const pw.TextStyle(
                  color: PdfColor.fromInt(0xFF667085), fontSize: 8))),
      pw.Expanded(
          child: pw.Text(value.isEmpty ? '-' : value,
              style: const pw.TextStyle(fontSize: 8.5)))
    ]));
pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(text.trim(),
        style: pw.TextStyle(
            fontSize: 7,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)));
