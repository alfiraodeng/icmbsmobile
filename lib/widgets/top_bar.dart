import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/notif_page.dart';
import '../services/database.dart';
import '../services/preference.dart';
import '../utils/globals.dart' as globals;

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({
    this.title,
    this.border,
    this.back = 1,
    this.onChanged,
    super.key,
  });

  final String? title;
  final InputBorder? border;
  final int back;
  final void Function(String)? onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  final _db = DatabaseService();
  final _profile = PreferenceService.getProfile();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  void _getData() {
    _db.rawQuery('''select tr.id from action_plans tr
      where tr.deleted_at is null and ((tr.pja_id=${_profile?.id} and tr.status<1) or (tr.pic_id=${_profile?.id} and tr.status<2))''').then((val) async {
      await PreferenceService.setNotif(val.length);
    });
  }

  Future<bool> _showBackDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batalkan Entri Data'),
          content: const Text(
            'Apakah anda akan membatalkan proses entri data?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int notif = PreferenceService.getNotif();
    return AppBar(
      surfaceTintColor: Colors.transparent,
      leading: (widget.back == 1)
          ? IconButton(
              icon: const Icon(Icons.chevron_left_rounded, size: 36),
              onPressed: () async {
                if (globals.goHome == true) {
                  globals.goHome = false;
                  globals.currentPage = 0;
                  await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(context, true);
              },
            )
          : (widget.back == 2)
              ? IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 36),
                  onPressed: () async {
                    bool isBack = await _showBackDialog();
                    if (isBack) {
                      if (!context.mounted) return;
                      Navigator.pop(context, true);
                    }
                  },
                )
              : null,
      title: Text(widget.title.toString()),
      centerTitle: false,
      toolbarHeight: 70,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications,
                size: 28,
                color: Colors.black45,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotifPage()),
                );
              },
            ),
            if (notif > 0)
              Container(
                margin: const EdgeInsets.only(top: 5, left: 25),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    '$notif',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Icons.account_circle,
            size: 28,
            color: Colors.black45,
          ),
          onPressed: () async {
            globals.currentPage = 4;
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        ),
        const SizedBox(width: 10)
      ],
    );
  }
}
