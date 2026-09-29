import 'package:flutter/material.dart';

import '../../utils/links.dart';
import '../../utils/routers.dart';
import '../../widgets/top_bar.dart';

class ExtraPage extends StatefulWidget {
  const ExtraPage({super.key});

  @override
  State<ExtraPage> createState() => _ExtraPageState();
}

class _ExtraPageState extends State<ExtraPage> {
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
      appBar: const TopBar(title: 'Performance Hub'),
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
          itemCount: listMenuExtra.length,
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
                    if (listMenuExtra[index].image.isNotEmpty)
                      Image.asset(
                        listMenuExtra[index].image,
                        fit: BoxFit.fitWidth,
                        height: 30,
                        opacity: AlwaysStoppedAnimation(
                          listMenuExtra[index].opacity,
                        ),
                      )
                    else
                      Opacity(
                        opacity: listMenuExtra[index].opacity,
                        child: Icon(
                          listMenuExtra[index].icon,
                          size: 34,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      listMenuExtra[index].title,
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
                routePage(context, listMenuExtra[index].route,
                    title: listMenuExtra[index].title);
              },
            );
          },
        ),
      ),
    );
  }
}
