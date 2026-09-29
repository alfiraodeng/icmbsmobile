import 'package:flutter/material.dart';

import '../../services/database.dart';
import '../../services/preference.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';
import '../../widgets/top_bar.dart';
import 'history_page.dart';

class OptionPage extends StatefulWidget {
  const OptionPage(this.module, {this.statusMgmt = false, super.key});

  final Module module;
  final bool? statusMgmt;

  @override
  State<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  final _db = DatabaseService();
  final _profile = PreferenceService.getProfile();
  int? _summary = 0;
  int? _action = 0;
  int? _monitor = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var qry = '';

      switch (widget.module) {
        case Module.inspection:
        case Module.inspectionDaily:
        case Module.inspectionWeekly:
        case Module.simama:
          qry = '''
          select count(1) as jml from inspection_trans tr
          where tr.deleted_at is null and tr.employee_id=${_profile?.id} and tr.category='${widget.module.name}'
          ''';
        default:
          qry = '''
          select count(1) as jml from hazard_trans tr
          where tr.deleted_at is null and tr.employee_id=${_profile?.id}
          ''';
      }

      if (qry != '') {
        _db.rawQuery(qry).then((val) {
          if (val.isNotEmpty) {
            if (!mounted) return;
            setState(() => _summary = val[0]['jml'] as int);
          }
        });
      }

      _db.rawQuery('''
        select count(1) as jml from action_plans tr
        where tr.deleted_at is null and ((tr.pja_id=${_profile?.id} and tr.status<1) or (tr.pic_id=${_profile?.id} and tr.status<2))
        and tr.category='${widget.module.name}'
        ''').then((val) {
        if (val.isNotEmpty) {
          if (!mounted) return;
          setState(() => _action = val[0]['jml'] as int);
        }
      });

      _db.rawQuery('''
        select count(1) as jml from action_plans tr
        where tr.deleted_at is null and ((tr.pja_id=${_profile?.id} and tr.status>0) or (tr.pic_id=${_profile?.id} and tr.status>1) or tr.employee_id=${_profile?.id})
        and tr.category='${widget.module.name}'
        ''').then((val) {
        if (val.isNotEmpty) {
          if (!mounted) return;
          setState(() => _monitor = val[0]['jml'] as int);
        }
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
      appBar: TopBar(title: pageTitle(widget.module)),
      body: Container(
        margin: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width,
        height: 290,
        decoration: BoxDecoration(
          color: Colors.white54,
          border: Border.all(color: Colors.indigo.shade200),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.summarize_outlined,
                color: Colors.indigo,
                size: 36,
              ),
              title: const Text(
                'Summary',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('$_summary Data'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.indigo.shade400,
                size: 16,
              ),
              contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              shape: Border(bottom: BorderSide(color: Colors.indigo.shade200)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      widget.module,
                      History.summary,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.send_to_mobile,
                color: Colors.indigo,
                size: 36,
              ),
              title: const Text(
                'Action',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('$_action Data'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.indigo.shade400,
                size: 16,
              ),
              contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              shape: Border(bottom: BorderSide(color: Colors.indigo.shade200)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      widget.module,
                      History.action,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.find_in_page,
                color: Colors.indigo,
                size: 36,
              ),
              title: const Text(
                'Monitoring',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text('$_monitor Data'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.indigo.shade400,
                size: 16,
              ),
              contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      widget.module,
                      History.monitoring,
                    ),
                  ),
                );
              },
            ),
          ],
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
