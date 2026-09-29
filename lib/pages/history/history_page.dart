import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/api.dart';
import '../../services/database.dart';
import '../../services/preference.dart';
import '../../services/sync.dart';
import '../../utils/enums.dart';
import '../../utils/globals.dart' as globals;
import '../../utils/helpers.dart';
import '../../widgets/snackbar_msg.dart';
import '../../widgets/top_bar.dart';
import 'history_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage(this.module, this.history, {this.lastId, super.key});

  final Module module;
  final History history;
  final int? lastId;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _scrollCtrl = ScrollController();
  final _db = DatabaseService();
  final _api = ApiService();
  final _profile = PreferenceService.getProfile();
  List<dynamic> _rawData = [];
  String _table = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
      if (widget.lastId == null) {
        Future.delayed(const Duration(seconds: 2), () => _getData());
        Future.delayed(const Duration(seconds: 4), () => _getData());
        Future.delayed(const Duration(seconds: 6), () => _getData());
        Future.delayed(const Duration(seconds: 8), () => _getData());
      }
    });
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  void _getData() {
    var qry = '';
    var select =
        '''select tr.*, me1.name as area_name, me2.name as location_name''';
    var joinArea =
        '''left join enum_masters me1 on me1.type='area' and me1.id=tr.area_id and me1.deleted_at is null
        left join enum_masters me2 on me2.type='location' and me2.id=tr.location_id and me2.deleted_at is null''';

    switch (widget.module) {
      case Module.inspection:
      case Module.inspectionDaily:
      case Module.inspectionWeekly:
      case Module.simama:
        qry = '''$select, im."name" as jenis_inspeksi,
        (select e.nama_lengkap from employees e where e.id=tr.pja_id) as pja_name,
        (select e.nama_lengkap from employees e where e.id=tr.inspektor1_id) as inspektor1_name,
        (select e.nama_lengkap from employees e where e.id=tr.inspektor2_id) as inspektor2_name,
        (select e.nama_lengkap from employees e where e.id=tr.inspektor3_id) as inspektor3_name,
        (select e.nama_lengkap from employees e where e.id=tr.inspektor4_id) as inspektor4_name,
        (select e.nama_lengkap from employees e where e.id=tr.inspektor5_id) as inspektor5_name,
        (select em."name" from enum_masters em where em."type"='shift' and em.id=tr.shift_id) as shift_name
        from inspection_trans tr $joinArea
        left join inspection_masters im on im.id=tr.inspection_id and im.deleted_at is null and im.ref_id is null
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} and tr.category='${widget.module.name}' order by tr.id desc''';
        _table = 'inspection_trans';
        break;
      case Module.hazard:
        qry = '''$select,
        (select hm."name" from hazard_masters hm where hm."type"='status' and hm.id=tr.hazard_id) as kategori_bahaya,
        (select hm."name" from hazard_masters hm where hm."type"='danger' and hm.id=tr.hazard_danger_id) as tingkat_resiko,
        (select hm."name" from hazard_masters hm where hm."type"='type' and hm.id=tr.hazard_type_id) as jenis_bahaya,
        (select hm."name" from hazard_masters hm where hm."type"='subtype' and hm.id=tr.hazard_subtype_id) as jenis_ketidaksesuaian,
        (select e.nama_lengkap from employees e where e.id=tr.pja_id) as pja_name
        from hazard_trans tr $joinArea
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} order by tr.id desc''';
        _table = 'hazard_trans';
        break;
      case Module.coaching:
        qry = '''$select from coaching_trans tr $joinArea
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} order by tr.id desc''';
        _table = 'coaching_trans';
        break;
      case Module.observation:
        qry = '''$select,
        (select me."name" from enum_masters me where me."type"='dept' and me.id=tr.dept_id) as departemen_pekerja_yang_diamati,
        (select om."name" from observation_masters om where om."type"='document' and om.id=tr.doc_id) as dokumen_pendukung,
        (select om."name" from observation_masters om where om."type"='risk' and om.id=tr.risk_id) as resiko_kritis
        from observation_trans tr $joinArea
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} order by tr.id desc''';
        _table = 'observation_trans';
        break;
      case Module.p2h:
        qry = '''select tr.*, mv.code as area_name, mv.type as location_name, 
        mv.type as jenis_kendaraan, mv.code as no_lambung_kendaraan, mv."name" as merek_kendaraan
        from p2h_trans tr
        left join vehicle_masters mv on mv.id=tr.vehicle_id and mv.deleted_at is null
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} order by tr.id desc''';
        _table = 'p2h_trans';
        break;
      case Module.p5m:
        qry = '''$select,
        (select pm."name" from p5m_masters pm where pm."type"='topic-p5m' and pm.id=tr.topic_id) as topic_name
        from p5m_trans tr $joinArea
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} order by tr.id desc''';
        _table = 'p5m_trans';
        break;
      case Module.safety:
        qry = '''$select from safety_trans tr $joinArea
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} order by tr.id desc''';
        _table = 'safety_trans';
        break;
      case Module.induction:
        qry = '''$select from k3_trans tr $joinArea
        where tr.deleted_at is null and tr.employee_id=${_profile?.id} order by tr.id desc''';
        _table = 'k3_trans';
        break;
      default:
        break;
    }

    if (widget.history == History.action) {
      qry = '''$select, 1 as sync_id,
      (select e.nama_lengkap from employees e where e.id=tr.pja_id) as pja_name,
      (select e.nama_lengkap from employees e where e.id=tr.pic_id) as pic_name
      from action_plans tr $joinArea
      where tr.deleted_at is null and ((tr.pja_id=${_profile?.id} and tr.status<1) or (tr.pic_id=${_profile?.id} and tr.status<2))
      and tr.category='${widget.module.name}'
      order by tr.id desc''';
      _table = '';
    }

    if (widget.history == History.monitoring) {
      qry = '''$select, 1 as sync_id,
      (select e.nama_lengkap from employees e where e.id=tr.pja_id) as pja_name,
      (select e.nama_lengkap from employees e where e.id=tr.pic_id) as pic_name
      from action_plans tr $joinArea
      where tr.deleted_at is null and ((tr.pja_id=${_profile?.id} and tr.status>0) or (tr.pic_id=${_profile?.id} and tr.status>1) or tr.employee_id=${_profile?.id})
      and tr.category='${widget.module.name}'
      order by tr.id desc''';
      _table = '';
    }

    if (qry != '') {
      _db.rawQuery(qry).then((val) {
        if (val.isNotEmpty) {
          debugPrint('--- $_table : ${val.length} ---');

          if (widget.lastId != null) {
            var lastData =
                val.where((e) => e['id'] as int == widget.lastId).toList();
            if (lastData.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryDetailPage(
                    widget.module,
                    widget.history,
                    lastData[0] as Map<String, dynamic>,
                  ),
                ),
              );
              return;
            }
          }

          if (!mounted) return;
          setState(() => _rawData = val.toList());
        }
      });
    }
  }

  void _feedBack(bool val) {
    if (val == true) {
      _getData();
      SnackBarMsg.success(context, 'Berhasil sinkron!');
    } else {
      SnackBarMsg.danger(context, 'Gagal sinkron!');
    }
  }

  Future<dynamic> _showBottomSheet(int index) {
    var sync = (_rawData[index]['sync_id'] == null) ? false : true;
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(
        maxHeight: 350,
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Tampilkan',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.remove_red_eye,
                  color: Colors.indigo.shade400,
                ),
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                shape:
                    Border(bottom: BorderSide(color: Colors.indigo.shade100)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoryDetailPage(
                        widget.module,
                        widget.history,
                        _rawData[index] as Map<String, dynamic>,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Sinkron',
                  style: TextStyle(
                    color: (sync) ? Colors.black45 : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.cloud_sync,
                  color: (sync) ? Colors.indigo.shade200 : Colors.indigo,
                ),
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                shape:
                    Border(bottom: BorderSide(color: Colors.indigo.shade100)),
                onTap: (sync)
                    ? null
                    : () {
                        switch (widget.module) {
                          case Module.inspection:
                          case Module.inspectionDaily:
                          case Module.inspectionWeekly:
                          case Module.simama:
                            syncTran(_db, _api, 'inspection',
                                    _rawData[index]['id'] as int)
                                .then((val) => _feedBack(val));
                            break;
                          default:
                            syncTran(_db, _api, widget.module.name,
                                    _rawData[index]['id'] as int)
                                .then((val) => _feedBack(val));
                            break;
                        }
                        Navigator.pop(context);
                      },
              ),
              ListTile(
                title: Text(
                  'Hapus Data',
                  style: TextStyle(
                    color: (sync) ? Colors.black45 : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Icon(
                  Icons.delete_forever,
                  color: (sync) ? Colors.indigo.shade200 : Colors.indigo,
                ),
                contentPadding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                onTap: (sync)
                    ? null
                    : () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Data'),
                              content: const Text(
                                'Apakah anda akan menghapus data?',
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    textStyle:
                                        Theme.of(context).textTheme.labelLarge,
                                  ),
                                  child: const Text('Ok'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _db
                                        .delete(_table,
                                            _rawData[index]['id'] as int)
                                        .then((val) {
                                      if (val > 0) {
                                        _db.execute(
                                            '''delete from ${_table.replaceAll('_trans', '')}_details 
                                            where tran_id=${_rawData[index]['id'] as int}''');
                                        if (!mounted) return;
                                        setState(
                                            () => _rawData.removeAt(index));
                                        SnackBarMsg.success(
                                            context, 'Data berhasil dihapus!');
                                      } else {
                                        SnackBarMsg.danger(
                                            context, 'Data gagal dihapus!');
                                      }
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
          title:
              '${titleCase(widget.history.name)} ${pageTitle(widget.module)}'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: (_rawData.isNotEmpty)
            ? ListView.builder(
                controller: _scrollCtrl,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rawData.length,
                itemBuilder: (context, index) {
                  var date = DateTime.parse(_rawData[index]['date']);
                  var sync =
                      (_rawData[index]['sync_id'] == null) ? false : true;
                  return Card(
                    color: Colors.white,
                    shadowColor: (sync) ? Colors.green : Colors.red,
                    child: ListTile(
                      title: Text(
                        titleCase(_rawData[index]['title'] ?? ''),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Note: ${titleCase(_rawData[index]['remark'] ?? '')}'),
                          Text(
                              'Area: ${titleCase(_rawData[index]['area_name'] ?? '')}'),
                          Text(
                              'Lokasi: ${titleCase(_rawData[index]['location_name'] ?? '')}'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                  '${DateFormat('dd/MM/yyyy').format(date)} ${_rawData[index]['time']}'),
                              Expanded(
                                child: Container(),
                              ),
                              (widget.history == History.summary)
                                  ? (sync)
                                      ? const Text('SDH SINKRON',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ))
                                      : const Text('BLM SINKRON',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ))
                                  : Text(
                                      '${globals.status[_rawData[index]['status'] as int]}',
                                      style: TextStyle(
                                        color: globals.statusColor[
                                            _rawData[index]['status'] as int],
                                        fontWeight: FontWeight.bold,
                                      )),
                            ],
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.indigo.shade400,
                        size: 18,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      onTap: () {
                        if (widget.history == History.summary) {
                          _showBottomSheet(index);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryDetailPage(
                                widget.module,
                                widget.history,
                                _rawData[index] as Map<String, dynamic>,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              )
            : Container(
                margin: const EdgeInsets.only(top: 100),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    const Image(
                      image: AssetImage('assets/images/no-data.png'),
                      width: 180,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Data ${pageTitle(widget.module)} Tidak Ditemukan!',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        onPressed: () => openPage(context, widget.module),
        child: const Icon(Icons.add, color: Colors.white, size: 40),
      ),
    );
  }
}
