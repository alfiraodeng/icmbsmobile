import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/helpers.dart';
import '../widgets/button_app.dart';
import '../widgets/upload_files.dart';
import 'success_page.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _note = TextEditingController();
  String? _image;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Image(
                image: AssetImage('assets/images/support.png'),
                width: 180,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tulis Kendala Anda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _note,
              minLines: 2,
              maxLines: 2,
              style: const TextStyle(fontSize: 16),
              onChanged: (String val) => setState(() {}),
            ),
            const SizedBox(height: 15),
            const Text(
              'Upload Foto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.camera_alt, color: Colors.grey),
                          title: const Text('Camera'),
                          onTap: () {
                            Navigator.pop(context);
                            Future<File?> imageFile =
                                pickImage(source: ImageSource.camera);
                            imageFile.then((value) {
                              if (value != null) {
                                setState(() => _image = value.path);
                              }
                            });
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.image, color: Colors.grey),
                          title: const Text('Gallery'),
                          onTap: () {
                            Navigator.pop(context);
                            Future<File?> imageFile =
                                pickImage(source: ImageSource.gallery);
                            imageFile.then((value) {
                              if (value != null) {
                                setState(() => _image = value.path);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image == null || _image == ''
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Upload Foto',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    : Image.file(File(_image!)),
              ),
            ),
            if (_image != null) const UploadFiles('Support', null),
            const SizedBox(height: 15),
            Container(
              alignment: Alignment.centerRight,
              child: buttonApp(
                label: 'KIRIM',
                onPressed: (_note.text == '')
                    ? null
                    : () async {
                        final Email email = Email(
                          body: _note.text,
                          subject: 'MBS SAP Technical Support',
                          recipients: ['system.integration@indexim.co.id'],
                          attachmentPaths: (_image == null) ? [] : [_image!],
                          isHTML: false,
                        );

                        await FlutterEmailSender.send(email);

                        if (!context.mounted) return;
                        await Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SuccessPage(
                                  msg:
                                      'Terima kasih, pesan Anda sudah kami terima.')),
                          (route) => false,
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
