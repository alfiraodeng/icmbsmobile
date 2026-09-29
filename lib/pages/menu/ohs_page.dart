import 'package:flutter/material.dart';

import '../../utils/links.dart';
import '../../utils/routers.dart';
import '../../widgets/top_bar.dart';

class OhsPage extends StatefulWidget {
  const OhsPage({super.key});

  @override
  State<OhsPage> createState() => _OhsPageState();
}

class _OhsPageState extends State<OhsPage> {
  @override
  void initState() {
    super.initState();

    /** */
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(title: 'OHS Program'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: listMenuOhs1.length,
          itemBuilder: (context, index) {
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.blueAccent,
              child: Card(
                elevation: 2,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (listMenuOhs1[index].image.isNotEmpty)
                      Image.asset(
                        listMenuOhs1[index].image,
                        fit: BoxFit.fitWidth,
                        height: 30,
                        opacity: AlwaysStoppedAnimation(
                          listMenuOhs1[index].opacity,
                        ),
                      )
                    else
                      Opacity(
                        opacity: listMenuOhs1[index].opacity,
                        child: Icon(
                          listMenuOhs1[index].icon,
                          size: 34,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      listMenuOhs1[index].title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              onTap: () {
                routePage(
                  context,
                  listMenuOhs1[index].route,
                  title: listMenuOhs1[index].title,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
