import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CiParameter {
  const CiParameter(this.id, this.title, this.group, this.weight,
      {this.critical = false, this.regulatory = false});

  final String id;
  final String title;
  final String group;
  final int weight;
  final bool critical;
  final bool regulatory;
}

class CiCatalog {
  static const fci = <CiParameter>[
    CiParameter(
        'F01', 'Kekerasan dan daya dukung lantai front', 'Kondisi Lantai', 10,
        critical: true),
    CiParameter('F02', 'Kerataan dan cross slope lantai', 'Kondisi Lantai', 6),
    CiParameter('F03', 'Lumpur, air dan genangan', 'Kondisi Lantai', 6,
        critical: true),
    CiParameter('F04', 'Lebar front dan ruang manuver', 'Geometri & Posisi', 8,
        critical: true),
    CiParameter('F05', 'Posisi truck saat loading', 'Geometri & Posisi', 6,
        critical: true),
    CiParameter(
        'F06', 'Posisi dan stabilitas excavator', 'Geometri & Posisi', 8,
        critical: true),
    CiParameter('F07', 'Tinggi dan geometri face/bench', 'Stabilitas Front', 8,
        critical: true),
    CiParameter(
        'F08', 'Material lepas, overhang dan rockfall', 'Stabilitas Front', 10,
        critical: true),
    CiParameter(
        'F09', 'Retakan atau indikasi ketidakstabilan', 'Stabilitas Front', 10,
        critical: true),
    CiParameter('F10', 'Segregasi material', 'Operasional', 7, critical: true),
    CiParameter('F11', 'Blind spot dan line of sight', 'Operasional', 5,
        critical: true),
    CiParameter('F12', 'Pengaturan traffic masuk dan keluar', 'Operasional', 4),
    CiParameter('F13', 'Antrean dan area parkir', 'Operasional', 3),
    CiParameter('F14', 'Drainase dan limpasan air', 'Lingkungan Kerja', 4,
        critical: true),
    CiParameter('F15', 'Penerangan dan jarak pandang', 'Lingkungan Kerja', 4,
        critical: true),
    CiParameter(
        'F16', 'Komunikasi dan positive confirmation', 'Kontrol Kritis', 5,
        critical: true),
  ];

  static const rci = <CiParameter>[
    CiParameter('R01', 'Lebar jalan dua arah', 'Geometri Jalan', 10,
        critical: true, regulatory: true),
    CiParameter('R02', 'Lebar jalan satu arah', 'Geometri Jalan', 10,
        critical: true, regulatory: true),
    CiParameter('R03', 'Tinggi safety berm', 'Proteksi Tepi', 10,
        critical: true),
    CiParameter('R04', 'Kontinuitas safety berm', 'Proteksi Tepi', 7,
        critical: true),
    CiParameter('R05', 'Cross fall', 'Geometri Jalan', 5, regulatory: true),
    CiParameter('R06', 'Longitudinal grade', 'Geometri Jalan', 8,
        regulatory: true),
    CiParameter('R07', 'Radius tikungan dan swept path', 'Geometri Jalan', 6,
        critical: true),
    CiParameter('R08', 'Superelevasi', 'Geometri Jalan', 5, critical: true),
    CiParameter('R09', 'Sight distance', 'Visibilitas', 6, critical: true),
    CiParameter('R10', 'Lubang atau pothole', 'Permukaan Jalan', 5,
        critical: true),
    CiParameter('R11', 'Rutting atau alur roda', 'Permukaan Jalan', 5,
        critical: true),
    CiParameter('R12', 'Corrugation', 'Permukaan Jalan', 3),
    CiParameter(
        'R13', 'Material lepas, spillage atau batu', 'Permukaan Jalan', 4,
        critical: true),
    CiParameter('R14', 'Soft spot dan kondisi subgrade', 'Permukaan Jalan', 5,
        critical: true),
    CiParameter('R15', 'Lumpur dan permukaan licin', 'Permukaan Jalan', 5,
        critical: true),
    CiParameter('R16', 'Debu dan jarak pandang', 'Visibilitas', 4,
        critical: true),
    CiParameter('R17', 'Side drain', 'Drainase', 4),
    CiParameter('R18', 'Culvert dan cross drain', 'Drainase', 4,
        critical: true),
    CiParameter('R19', 'Genangan dan water crossing', 'Drainase', 5,
        critical: true),
    CiParameter('R20', 'Erosi dan scouring', 'Drainase', 4, critical: true),
    CiParameter('R21', 'Kontrol persimpangan', 'Traffic Control', 5,
        critical: true),
    CiParameter('R22', 'Rambu dan delineator', 'Traffic Control', 3),
    CiParameter('R23', 'Penerangan', 'Visibilitas', 3, critical: true),
    CiParameter('R24', 'Kemacetan dan obstruction', 'Traffic Control', 3,
        critical: true),
    CiParameter(
        'R25', 'Kontrol roadwork dan diversion sementara', 'Traffic Control', 5,
        critical: true),
  ];

  static const dci = <CiParameter>[
    CiParameter('D01', 'Stabilitas tepi disposal', 'Stabilitas Disposal', 12,
        critical: true),
    CiParameter('D02', 'Tension crack', 'Stabilitas Disposal', 12,
        critical: true),
    CiParameter(
        'D03', 'Penurunan tanah dan sloughing', 'Stabilitas Disposal', 8,
        critical: true),
    CiParameter('D04', 'Tinggi bundwall', 'Proteksi Tepi', 8, critical: true),
    CiParameter('D05', 'Kontinuitas bundwall', 'Proteksi Tepi', 8,
        critical: true),
    CiParameter('D06', 'Daya dukung tanah', 'Kondisi Area', 8, critical: true),
    CiParameter('D07', 'Lumpur dan saturasi', 'Kondisi Area', 5,
        critical: true),
    CiParameter('D08', 'Area manuver', 'Operasional Dumping', 6,
        critical: true),
    CiParameter(
        'D09', 'Approach grade dan cross slope', 'Operasional Dumping', 4,
        critical: true),
    CiParameter('D10', 'Jarak dumping dan stand-off', 'Operasional Dumping', 10,
        critical: true),
    CiParameter('D11', 'Ketersediaan dozer', 'Sumber Daya', 4, critical: true),
    CiParameter('D12', 'Spotter atau control person', 'Kontrol Operasional', 4,
        critical: true),
    CiParameter('D13', 'Urutan dan arah dumping', 'Kontrol Operasional', 4,
        critical: true),
    CiParameter('D14', 'Separasi traffic dan antrean', 'Kontrol Operasional', 4,
        critical: true),
    CiParameter('D15', 'Drainase dan air di bawah tepi', 'Lingkungan Area', 5,
        critical: true),
    CiParameter('D16', 'Penerangan dan jarak pandang', 'Lingkungan Area', 4,
        critical: true),
    CiParameter('D17', 'Radio dan positive confirmation', 'Kontrol Kritis', 4,
        critical: true),
    CiParameter('D18', 'Rekomendasi geoteknik terkini', 'Kontrol Kritis', 10,
        critical: true),
  ];

  static List<CiParameter> forType(String type) => switch (type) {
        'RCI' => rci,
        'DCI' => dci,
        _ => fci,
      };
}

class CiAnswer {
  CiAnswer(
      {required this.parameterId,
      this.score,
      this.value = '',
      this.unit = '',
      this.note = '',
      this.criticalFailure = false});
  final String parameterId;
  int? score;
  String value;
  String unit;
  String note;
  bool criticalFailure;

  Map<String, dynamic> toJson() => {
        'parameterId': parameterId,
        'score': score,
        'value': value,
        'unit': unit,
        'note': note,
        'criticalFailure': criticalFailure
      };
  factory CiAnswer.fromJson(Map<String, dynamic> json) => CiAnswer(
      parameterId: '${json['parameterId']}',
      score: json['score'] as int?,
      value: '${json['value'] ?? ''}',
      unit: '${json['unit'] ?? ''}',
      note: '${json['note'] ?? ''}',
      criticalFailure: json['criticalFailure'] == true);
}

class CiAssessment {
  CiAssessment(
      {required this.id,
      required this.type,
      required this.assessorName,
      required this.assessorNik,
      required this.companyId,
      required this.location,
      required this.coordinate,
      required this.assessedAt,
      required this.shift,
      required this.weather,
      required this.areaOwner,
      required this.context,
      required this.ruleVersion,
      required this.answers,
      required this.index,
      required this.band,
      required this.operationalStatus,
      required this.criticalOverride,
      required this.consequence,
      required this.likelihood,
      required this.exposure,
      required this.priority,
      required this.temporaryControls,
      required this.action,
      required this.actionOwner,
      required this.dueDate,
      required this.validUntil,
      required this.evidencePaths,
      required this.status,
      this.verificationNotes = '',
      this.verifiedAt});
  final String id,
      type,
      assessorName,
      assessorNik,
      location,
      coordinate,
      shift,
      weather,
      areaOwner,
      context,
      ruleVersion,
      band,
      operationalStatus,
      exposure,
      priority,
      temporaryControls,
      action,
      actionOwner,
      status,
      verificationNotes;
  final int? companyId;
  final DateTime assessedAt, dueDate, validUntil;
  final DateTime? verifiedAt;
  final List<CiAnswer> answers;
  final List<String> evidencePaths;
  final double index;
  final bool criticalOverride;
  final int consequence, likelihood;

  CiAssessment copyWith(
          {String? status, String? verificationNotes, DateTime? verifiedAt}) =>
      CiAssessment(
          id: id,
          type: type,
          assessorName: assessorName,
          assessorNik: assessorNik,
          companyId: companyId,
          location: location,
          coordinate: coordinate,
          assessedAt: assessedAt,
          shift: shift,
          weather: weather,
          areaOwner: areaOwner,
          context: context,
          ruleVersion: ruleVersion,
          answers: answers,
          index: index,
          band: band,
          operationalStatus: operationalStatus,
          criticalOverride: criticalOverride,
          consequence: consequence,
          likelihood: likelihood,
          exposure: exposure,
          priority: priority,
          temporaryControls: temporaryControls,
          action: action,
          actionOwner: actionOwner,
          dueDate: dueDate,
          validUntil: validUntil,
          evidencePaths: evidencePaths,
          status: status ?? this.status,
          verificationNotes: verificationNotes ?? this.verificationNotes,
          verifiedAt: verifiedAt ?? this.verifiedAt);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'assessorName': assessorName,
        'assessorNik': assessorNik,
        'companyId': companyId,
        'location': location,
        'coordinate': coordinate,
        'assessedAt': assessedAt.toIso8601String(),
        'shift': shift,
        'weather': weather,
        'areaOwner': areaOwner,
        'context': context,
        'ruleVersion': ruleVersion,
        'answers': answers.map((e) => e.toJson()).toList(),
        'index': index,
        'band': band,
        'operationalStatus': operationalStatus,
        'criticalOverride': criticalOverride,
        'consequence': consequence,
        'likelihood': likelihood,
        'exposure': exposure,
        'priority': priority,
        'temporaryControls': temporaryControls,
        'action': action,
        'actionOwner': actionOwner,
        'dueDate': dueDate.toIso8601String(),
        'validUntil': validUntil.toIso8601String(),
        'evidencePaths': evidencePaths,
        'status': status,
        'verificationNotes': verificationNotes,
        'verifiedAt': verifiedAt?.toIso8601String()
      };
  factory CiAssessment.fromJson(Map<String, dynamic> j) => CiAssessment(
      id: '${j['id']}',
      type: '${j['type']}',
      assessorName: '${j['assessorName']}',
      assessorNik: '${j['assessorNik']}',
      companyId: j['companyId'] as int?,
      location: '${j['location']}',
      coordinate: '${j['coordinate']}',
      assessedAt: DateTime.parse('${j['assessedAt']}'),
      shift: '${j['shift']}',
      weather: '${j['weather']}',
      areaOwner: '${j['areaOwner']}',
      context: '${j['context']}',
      ruleVersion: '${j['ruleVersion']}',
      answers: (j['answers'] as List)
          .map((e) => CiAnswer.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      index: (j['index'] as num).toDouble(),
      band: '${j['band']}',
      operationalStatus: '${j['operationalStatus']}',
      criticalOverride: j['criticalOverride'] == true,
      consequence: j['consequence'] as int,
      likelihood: j['likelihood'] as int,
      exposure: '${j['exposure']}',
      priority: '${j['priority']}',
      temporaryControls: '${j['temporaryControls']}',
      action: '${j['action']}',
      actionOwner: '${j['actionOwner']}',
      dueDate: DateTime.parse('${j['dueDate']}'),
      validUntil: DateTime.parse('${j['validUntil']}'),
      evidencePaths: List<String>.from(j['evidencePaths'] ?? const []),
      status: '${j['status']}',
      verificationNotes: '${j['verificationNotes'] ?? ''}',
      verifiedAt: j['verifiedAt'] == null
          ? null
          : DateTime.tryParse('${j['verifiedAt']}'));
}

class CiRules {
  static double index(List<CiAnswer> answers, List<CiParameter> params) {
    var score = 0.0, maximum = 0.0;
    for (final answer in answers) {
      if (answer.score == null) continue;
      final parameter = params.firstWhere((e) => e.id == answer.parameterId);
      score += answer.score! * parameter.weight;
      maximum += 5 * parameter.weight;
    }
    return maximum == 0 ? 0 : score / maximum * 100;
  }

  static String band(double value) => value >= 90
      ? 'GOOD'
      : value >= 80
          ? 'ACCEPTABLE'
          : value >= 65
              ? 'DEGRADED'
              : value >= 50
                  ? 'POOR'
                  : 'CRITICAL';
  static String status(double value, bool override) => override || value < 50
      ? 'STOP / CLOSE'
      : value < 65
          ? 'RESTRICTED'
          : value < 80
              ? 'OPEN WITH CONDITION'
              : 'READY / OPEN';
  static String priority(
      int consequence, int likelihood, String exposure, bool override) {
    final risk = consequence * likelihood +
        (exposure == 'High'
            ? 5
            : exposure == 'Medium'
                ? 2
                : 0);
    if (override || risk >= 20) return 'P1 - Immediate';
    if (risk >= 15) return 'P2 - ≤ 4 jam';
    if (risk >= 9) return 'P3 - ≤ 24 jam';
    if (risk >= 4) return 'P4 - 3–7 hari';
    return 'Monitor';
  }
}

class CiStorage {
  static const _key = 'ci_assessments_v1';
  static Future<List<CiAssessment>> load() async {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => CiAssessment.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      list.sort((a, b) => b.assessedAt.compareTo(a.assessedAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(CiAssessment item) async {
    final list = await load();
    list.removeWhere((e) => e.id == item.id);
    list.insert(0, item);
    await (await SharedPreferences.getInstance())
        .setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }
}
