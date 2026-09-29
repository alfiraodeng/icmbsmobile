import 'package:flutter/material.dart';

import '../../utils/links.dart';
import '../../utils/routers.dart';
import '../../widgets/top_bar.dart';

class SapPage extends StatefulWidget {
  const SapPage({super.key});

  @override
  State<SapPage> createState() => _SapPageState();
}

class _SapPageState extends State<SapPage> {
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
      appBar: const TopBar(title: 'Safety Accountability Program'),
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
          itemCount: listMenuSap.length,
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
                    if (listMenuSap[index].image.isNotEmpty)
                      Image.asset(
                        listMenuSap[index].image,
                        fit: BoxFit.fitWidth,
                        height: 30,
                        opacity:
                            AlwaysStoppedAnimation(listMenuSap[index].opacity),
                      )
                    else
                      Opacity(
                        opacity: listMenuSap[index].opacity,
                        child: Icon(
                          listMenuSap[index].icon,
                          size: 34,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      listMenuSap[index].title,
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
                routePage(context, listMenuSap[index].route,
                    title: listMenuSap[index].title);
              },
            );
          },
        ),
      ),
    );
  }
}
