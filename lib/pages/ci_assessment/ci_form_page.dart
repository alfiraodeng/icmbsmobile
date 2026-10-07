import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../services/preference.dart';
import '../../widgets/sap_form_widgets.dart';
import '../../widgets/top_bar.dart';
import 'ci_model.dart';
import 'ci_page.dart';

const _navy = Color(0xFF123B63);
const _cyan = Color(0xFF0EA5A8);
const _surface = Color(0xFFF4F7FA);

class CiFormPage extends StatefulWidget {
  const CiFormPage(this.type, {super.key});
  final String type;

  @override
  State<CiFormPage> createState() => _CiFormPageState();
}

class _CiFormPageState extends State<CiFormPage> {
  static const _steps = [
    'Konteks',
    'Standar',
    'Penilaian',
    'Risiko',
    'Tindakan',
    'Review'
  ];
  final _profile = PreferenceService.getProfile();
  final _location = TextEditingController();
  final _coordinate = TextEditingController();
  final _areaOwner = TextEditingController();
  final _context = TextEditingController();
  final _ruleVersion =
      TextEditingController(text: 'Condition Index Rule Set v1.0');
  final _temporaryControls = TextEditingController();
  final _action = TextEditingController();
  final _actionOwner = TextEditingController();
  late final List<CiAnswer> _answers;
  final List<String> _evidence = [];
  int _step = 0;
  int? _companyId;
  String _shift = 'Day Shift';
  String _weather = 'Cerah';
  int _consequence = 3;
  int _likelihood = 3;
  String _exposure = 'Medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  DateTime _validUntil = DateTime.now().add(const Duration(days: 1));
  bool _standardConfirmed = false;
  bool _saving = false;

  List<CiParameter> get _parameters => CiCatalog.forType(widget.type);
  bool get _criticalOverride => _answers.any((a) => a.criticalFailure);
  double get _index => CiRules.index(_answers, _parameters);
  String get _band => CiRules.band(_index);
  String get _operationalStatus => CiRules.status(_index, _criticalOverride);
  String get _priority =>
      CiRules.priority(_consequence, _likelihood, _exposure, _criticalOverride);

  @override
  void initState() {
    super.initState();
    _companyId = _profile?.companyId;
    _areaOwner.text = _profile?.depart ?? '';
    _answers = _parameters.map((e) => CiAnswer(parameterId: e.id)).toList();
    WidgetsBinding.instance.addPostFrameCallback((_) => fillGpsCoordinate(
        context, _coordinate, () => setState(() {}),
        silent: true));
  }

  @override
  void dispose() {
    for (final controller in [
      _location,
      _coordinate,
      _areaOwner,
      _context,
      _ruleVersion,
      _temporaryControls,
      _action,
      _actionOwner
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  bool _validate() {
    if (_step == 0 &&
        (_companyId == null ||
            _location.text.trim().isEmpty ||
            _areaOwner.text.trim().isEmpty ||
            _context.text.trim().isEmpty)) {
      _message(
          'Lengkapi perusahaan, lokasi, pemilik area, dan konteks asesmen.');
      return false;
    }
    if (_step == 1 && !_standardConfirmed) {
      _message('Konfirmasi standar dan desain aktif sebelum melanjutkan.');
      return false;
    }
    if (_step == 2 &&
        _answers.any((e) => e.score == null && e.value != '__NA__')) {
      _message('Nilai seluruh parameter. Pilih N/A bila tidak berlaku.');
      return false;
    }
    if (_step == 4 &&
        (_temporaryControls.text.trim().isEmpty ||
            _action.text.trim().isEmpty ||
            _actionOwner.text.trim().isEmpty)) {
      _message('Lengkapi kontrol sementara, action, dan PIC action.');
      return false;
    }
    return true;
  }

  Future<void> _next() async {
    if (!_validate()) return;
    if (_step < _steps.length - 1) {
      setState(() => _step++);
      return;
    }
    await _save();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final item = CiAssessment(
      id: '${widget.type}-${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}',
      type: widget.type,
      assessorName: _profile?.namaLengkap ?? '-',
      assessorNik: _profile?.noNik ?? '-',
      companyId: _companyId,
      location: _location.text.trim(),
      coordinate: _coordinate.text.trim(),
      assessedAt: DateTime.now(),
      shift: _shift,
      weather: _weather,
      areaOwner: _areaOwner.text.trim(),
      context: _context.text.trim(),
      ruleVersion: _ruleVersion.text.trim(),
      answers: _answers,
      index: _index,
      band: _band,
      operationalStatus: _operationalStatus,
      criticalOverride: _criticalOverride,
      consequence: _consequence,
      likelihood: _likelihood,
      exposure: _exposure,
      priority: _priority,
      temporaryControls: _temporaryControls.text.trim(),
      action: _action.text.trim(),
      actionOwner: _actionOwner.text.trim(),
      dueDate: _dueDate,
      validUntil: _validUntil,
      evidencePaths: [..._evidence],
      status: _operationalStatus == 'READY / OPEN' ? 'Closed' : 'Open',
    );
    await CiStorage.save(item);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => CiDetailPage(item)));
  }

  Future<void> _pickDate(bool validity) async {
    final current = validity ? _validUntil : _dueDate;
    final value = await showDatePicker(
        context: context,
        initialDate: current,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (value != null) {
      setState(() => validity ? _validUntil = value : _dueDate = value);
    }
  }

  Future<void> _pickEvidence() async {
    if (_evidence.length >= 5) {
      _message('Maksimal 5 foto bukti.');
      return;
    }
    final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
                child: Wrap(children: [
              ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Ambil Foto'),
                  onTap: () => Navigator.pop(context, ImageSource.camera)),
              ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery)),
            ])));
    if (source == null) return;
    final picker = ImagePicker();
    if (source == ImageSource.camera) {
      final image = await picker.pickImage(
          source: source, imageQuality: 78, maxWidth: 1600);
      if (image != null) setState(() => _evidence.add(image.path));
    } else {
      final images =
          await picker.pickMultiImage(imageQuality: 78, maxWidth: 1600);
      setState(() => _evidence
          .addAll(images.take(5 - _evidence.length).map((e) => e.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: TopBar(title: _typeName(widget.type), back: 2),
      body: Column(children: [
        _Progress(step: _step, steps: _steps),
        Expanded(
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: SingleChildScrollView(
                    key: ValueKey(_step),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    child: _buildStep()))),
      ]),
      bottomNavigationBar: SafeArea(
          child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
        child: Row(children: [
          if (_step > 0) ...[
            IconButton.filledTonal(
                onPressed: () => setState(() => _step--),
                icon: const Icon(Icons.arrow_back_rounded)),
            const SizedBox(width: 10)
          ],
          Expanded(
              child: FilledButton.icon(
                  onPressed: _saving ? null : _next,
                  style: FilledButton.styleFrom(
                      backgroundColor: _navy,
                      minimumSize: const Size.fromHeight(50)),
                  icon: Icon(_step == _steps.length - 1
                      ? Icons.save_rounded
                      : Icons.arrow_forward_rounded),
                  label: Text(_saving
                      ? 'Menyimpan...'
                      : _step == _steps.length - 1
                          ? 'Simpan Assessment'
                          : 'Lanjut'))),
        ]),
      )),
    );
  }

  Widget _buildStep() => switch (_step) {
        0 => _contextStep(),
        1 => _standardStep(),
        2 => _assessmentStep(),
        3 => _riskStep(),
        4 => _actionStep(),
        _ => _reviewStep()
      };

  Widget _contextStep() {
    final hint = switch (widget.type) {
      'RCI' =>
        'Kelas jalan, ruas/segment, arah, STA awal–akhir, dan design vehicle',
      'DCI' =>
        'Nama disposal, lift/elevasi, area dumping, dan referensi geoteknik',
      _ => 'Nama loading front, fleet, material, bench, dan alat utama',
    };
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Lead(
          icon: Icons.pin_drop_rounded,
          title: 'Lokasi & Konteks ${_typeName(widget.type)}',
          subtitle: 'Data konteks menentukan standar teknis yang berlaku.'),
      CompanyDropdown(
          initialCompanyId: _profile?.companyId,
          initialCompanyName: _profile?.company,
          onChanged: (v) => setState(() => _companyId = v)),
      _label('Lokasi / Area'),
      _field(
          _location, 'Contoh: Pit 1 - North Block', Icons.location_on_outlined),
      _label('Koordinat GPS'),
      TextField(
          controller: _coordinate,
          readOnly: true,
          decoration: gpsInputDecoration(
                  context: context,
                  onPressed: () => fillGpsCoordinate(
                      context, _coordinate, () => setState(() {})),
                  iconColor: _cyan)
              .copyWith(hintText: 'Diambil otomatis dari perangkat')),
      const SizedBox(height: 14),
      _label('Pemilik Area / Departemen'),
      _field(_areaOwner, 'Departemen yang bertanggung jawab',
          Icons.apartment_rounded),
      _label('Detail Konteks'),
      TextField(
          controller: _context,
          maxLines: 4,
          decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 62),
                  child: Icon(Icons.description_outlined)))),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
            child: _dropdown(
                'Shift',
                _shift,
                const ['Day Shift', 'Night Shift'],
                (v) => setState(() => _shift = v!))),
        const SizedBox(width: 10),
        Expanded(
            child: _dropdown(
                'Cuaca',
                _weather,
                const ['Cerah', 'Berawan', 'Hujan', 'Kabut'],
                (v) => setState(() => _weather = v!)))
      ]),
    ]);
  }

  Widget _standardStep() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Lead(
            icon: Icons.rule_folder_rounded,
            title: 'Standar yang Berlaku',
            subtitle:
                'Pastikan penilaian memakai dokumen resmi terbaru untuk lokasi dan konfigurasi aktual.'),
        _infoCard(Icons.account_tree_rounded, 'Urutan acuan',
            'Regulasi dan standar perusahaan → design criteria → rekomendasi geoteknik → SOP/WI → temporary control yang disetujui.'),
        _infoCard(Icons.straighten_rounded, 'Nilai batas teknis',
            'Gunakan dimensi, grade, jarak aman, dan kriteria penerimaan dari dokumen aktif. Aplikasi tidak mengganti persetujuan Engineering, Geotechnical, atau KTT.'),
        _infoCard(Icons.calculate_rounded, 'Metode indeks',
            'Skor 5 Baik, 4 Dapat Diterima, 3 Menurun, 2 Buruk, 1 Kritis. N/A tidak masuk denominator. Kegagalan kontrol kritis mengesampingkan nilai indeks.'),
        const SizedBox(height: 8),
        _label('Versi Rule Set / Referensi Dokumen'),
        _field(_ruleVersion, 'Contoh: Haul Road Design Rev. 3',
            Icons.history_edu_rounded),
        CheckboxListTile(
            value: _standardConfirmed,
            onChanged: (v) => setState(() => _standardConfirmed = v == true),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            activeColor: _cyan,
            title: const Text('Saya sudah memeriksa standar/desain aktif',
                style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text(
                'Konteks, unit, dan kondisi lapangan sesuai dokumen yang dipilih.')),
      ]);

  Widget _assessmentStep() {
    final groups = <String, List<CiParameter>>{};
    for (final item in _parameters) {
      groups.putIfAbsent(item.group, () => []).add(item);
    }
    final done =
        _answers.where((e) => e.score != null || e.value == '__NA__').length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _Lead(
          icon: Icons.fact_check_rounded,
          title: 'Parameter Teknis',
          subtitle:
              '$done dari ${_parameters.length} parameter telah dinilai.'),
      LinearProgressIndicator(
          value: done / _parameters.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
          color: _cyan,
          backgroundColor: const Color(0xFFDCE7EF)),
      const SizedBox(height: 14),
      ...groups.entries.map((group) => _parameterGroup(group.key, group.value)),
    ]);
  }

  Widget _parameterGroup(String title, List<CiParameter> params) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: Colors.white,
        child: ExpansionTile(
            initiallyExpanded: true,
            leading: const CircleAvatar(
                backgroundColor: Color(0xFFE6F6F6),
                child: Icon(Icons.engineering_rounded, color: _cyan)),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${params.length} parameter'),
            children: params.map(_parameterCard).toList()),
      );

  Widget _parameterCard(CiParameter item) {
    final answer = _answers.firstWhere((e) => e.parameterId == item.id);
    const options = <int?, String>{
      5: 'Baik',
      4: 'Diterima',
      3: 'Menurun',
      2: 'Buruk',
      1: 'Kritis',
      null: 'N/A'
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE8EEF3)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text('${item.id}  ${item.title}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, height: 1.3))),
          const SizedBox(width: 8),
          _tag('W${item.weight}', _navy),
          if (item.regulatory) ...[
            const SizedBox(width: 4),
            _tag('REG', const Color(0xFF7C3AED))
          ],
          if (item.critical) ...[
            const SizedBox(width: 4),
            _tag('CRITICAL', const Color(0xFFDC2626))
          ]
        ]),
        const SizedBox(height: 10),
        Wrap(
            spacing: 6,
            runSpacing: 6,
            children: options.entries.map((entry) {
              final selected = answer.score == entry.key &&
                  (entry.key != null || answer.value == '__NA__');
              return ChoiceChip(
                  label: Text(
                      entry.key == null ? 'N/A' : '${entry.key} ${entry.value}',
                      style: const TextStyle(fontSize: 11)),
                  selected: selected,
                  selectedColor: const Color(0xFFD8F3F3),
                  side: BorderSide(
                      color: selected ? _cyan : const Color(0xFFD5DEE7)),
                  onSelected: (_) => setState(() {
                        answer.score = entry.key;
                        if (entry.key == null) {
                          answer.value = '__NA__';
                        } else if (answer.value == '__NA__') {
                          answer.value = '';
                        }
                        answer.criticalFailure =
                            item.critical && entry.key == 1;
                      }));
            }).toList()),
        if (answer.score != null) ...[
          const SizedBox(height: 10),
          TextFormField(
              initialValue: answer.note,
              onChanged: (v) => answer.note = v,
              decoration: const InputDecoration(
                  labelText: 'Catatan / temuan', isDense: true)),
          if (item.critical)
            SwitchListTile(
                value: answer.criticalFailure,
                onChanged: (v) => setState(() => answer.criticalFailure = v),
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeThumbColor: const Color(0xFFDC2626),
                title: const Text('Kontrol kritis gagal',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))
        ],
      ]),
    );
  }

  Widget _riskStep() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Lead(
            icon: Icons.crisis_alert_rounded,
            title: 'Risiko & Keputusan',
            subtitle:
                'Nilai risiko residual berdasarkan kondisi aktual di lapangan.'),
        _resultBanner(),
        const SizedBox(height: 16),
        _scoreSelector('Konsekuensi', _consequence,
            (v) => setState(() => _consequence = v)),
        const SizedBox(height: 14),
        _scoreSelector(
            'Kemungkinan', _likelihood, (v) => setState(() => _likelihood = v)),
        const SizedBox(height: 14),
        _label('Paparan'),
        SegmentedButton<String>(segments: const [
          ButtonSegment(value: 'Low', label: Text('Low')),
          ButtonSegment(value: 'Medium', label: Text('Medium')),
          ButtonSegment(value: 'High', label: Text('High'))
        ], selected: {
          _exposure
        }, onSelectionChanged: (v) => setState(() => _exposure = v.first)),
        const SizedBox(height: 18),
        _infoCard(Icons.schedule_rounded, 'Prioritas Tindak Lanjut', _priority),
      ]);

  Widget _actionStep() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Lead(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Kontrol & Action',
            subtitle:
                'Tetapkan perlindungan sementara, PIC, target, dan masa berlaku keputusan.'),
        _label('Kontrol Sementara'),
        _area(_temporaryControls,
            'Contoh: Tutup jalur, pasang barricade, grader dan water truck standby'),
        _label('Corrective Action'),
        _area(
            _action, 'Uraikan tindakan permanen dan kriteria penyelesaiannya'),
        _label('PIC / Action Owner'),
        _field(_actionOwner, 'Nama atau departemen penanggung jawab',
            Icons.person_outline_rounded),
        Row(children: [
          Expanded(
              child: _dateTile(
                  'Target Selesai', _dueDate, () => _pickDate(false))),
          const SizedBox(width: 10),
          Expanded(
              child: _dateTile(
                  'Berlaku Sampai', _validUntil, () => _pickDate(true)))
        ]),
        const SizedBox(height: 16),
        Row(children: [
          const Expanded(
              child: Text('Bukti Foto',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
          Text('${_evidence.length}/5',
              style:
                  const TextStyle(color: _cyan, fontWeight: FontWeight.w800)),
          IconButton.filledTonal(
              onPressed: _pickEvidence,
              icon: const Icon(Icons.add_a_photo_rounded))
        ]),
        if (_evidence.isNotEmpty)
          SizedBox(
              height: 92,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _evidence.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_evidence[i]),
                                width: 92, height: 92, fit: BoxFit.cover)),
                        Positioned(
                            right: 2,
                            top: 2,
                            child: InkWell(
                                onTap: () =>
                                    setState(() => _evidence.removeAt(i)),
                                child: const CircleAvatar(
                                    radius: 11,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close,
                                        size: 14, color: Colors.white))))
                      ]))),
      ]);

  Widget _reviewStep() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Lead(
            icon: Icons.task_alt_rounded,
            title: 'Review & Simpan',
            subtitle:
                'Periksa kembali hasil sebelum disimpan sebagai rekaman asesmen.'),
        _resultBanner(),
        const SizedBox(height: 14),
        _review('Assessment', _typeName(widget.type)),
        _review('Lokasi', '${_location.text}\n${_coordinate.text}'),
        _review('Pemilik Area', _areaOwner.text),
        _review('Konteks', _context.text),
        _review('Rule Set', _ruleVersion.text),
        _review('Risiko',
            'C$_consequence × L$_likelihood • Exposure $_exposure\n$_priority'),
        _review('Kontrol Sementara', _temporaryControls.text),
        _review('Action / PIC', '${_action.text}\nPIC: ${_actionOwner.text}'),
        _review('Target / Validitas',
            '${DateFormat('dd MMM yyyy').format(_dueDate)} / ${DateFormat('dd MMM yyyy').format(_validUntil)}'),
      ]);

  Widget _resultBanner() {
    final color = _criticalOverride || _index < 50
        ? const Color(0xFFDC2626)
        : _index < 80
            ? const Color(0xFFF59E0B)
            : const Color(0xFF059669);
    return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: .35))),
        child: Row(children: [
          SizedBox(
              width: 72,
              height: 72,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                    value: _index / 100,
                    strokeWidth: 8,
                    color: color,
                    backgroundColor: color.withValues(alpha: .15)),
                Text(_index.toStringAsFixed(0),
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: color))
              ])),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(_band,
                    style: TextStyle(
                        color: color,
                        fontSize: 17,
                        fontWeight: FontWeight.w900)),
                Text(_operationalStatus,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                if (_criticalOverride)
                  const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('Critical override aktif',
                          style: TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w700)))
              ]))
        ]));
  }

  Widget _scoreSelector(String title, int value, ValueChanged<int> changed) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _label(title),
        Row(
            children: List.generate(5, (i) {
          final n = i + 1;
          return Expanded(
              child: Padding(
                  padding: EdgeInsets.only(right: n == 5 ? 0 : 7),
                  child: InkWell(
                      onTap: () => changed(n),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: value == n ? _navy : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: value == n
                                      ? _navy
                                      : const Color(0xFFD5DEE7))),
                          child: Text('$n',
                              style: TextStyle(
                                  color: value == n ? Colors.white : _navy,
                                  fontWeight: FontWeight.w800))))));
        }))
      ]);
  Widget _dateTile(String title, DateTime date, VoidCallback tap) => InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD5DEE7))),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
            const SizedBox(height: 5),
            Row(children: [
              const Icon(Icons.calendar_month_rounded, size: 18, color: _cyan),
              const SizedBox(width: 6),
              Text(DateFormat('dd MMM yy').format(date),
                  style: const TextStyle(fontWeight: FontWeight.w700))
            ])
          ])));
  Widget _review(String label, String value) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
        const SizedBox(height: 3),
        Text(value.isEmpty ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35))
      ]));
}

String _typeName(String type) => switch (type) {
      'RCI' => 'Road Condition Index',
      'DCI' => 'Disposal Condition Index',
      _ => 'Front Condition Index'
    };

Widget _tag(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(6)),
    child: Text(text,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)));
Widget _field(TextEditingController c, String hint, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
        controller: c,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon))));
Widget _area(TextEditingController c, String hint) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
        controller: c,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: hint)));
Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF26384A))));
Widget _dropdown(String label, String value, List<String> items,
        ValueChanged<String?> changed) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: changed)
    ]);
Widget _infoCard(IconData icon, String title, String body) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CircleAvatar(
          backgroundColor: const Color(0xFFE6F6F6),
          child: Icon(icon, color: _cyan)),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(color: Colors.blueGrey, height: 1.4))
      ]))
    ]));

class _Lead extends StatelessWidget {
  const _Lead(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 23,
            backgroundColor: const Color(0xFFE0F2FE),
            child: Icon(icon, color: _navy)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF172033))),
          const SizedBox(height: 3),
          Text(subtitle,
              style: const TextStyle(color: Colors.blueGrey, height: 1.35))
        ]))
      ]));
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step, required this.steps});
  final int step;
  final List<String> steps;
  @override
  Widget build(BuildContext context) => Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(children: [
        Row(children: [
          Text('${step + 1}/${steps.length}',
              style:
                  const TextStyle(color: _cyan, fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(steps[step],
                  style: const TextStyle(fontWeight: FontWeight.w800))),
          Text('${((step + 1) / steps.length * 100).round()}%',
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey))
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(
            value: (step + 1) / steps.length,
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
            color: _cyan,
            backgroundColor: const Color(0xFFE2E8F0))
      ]));
}
