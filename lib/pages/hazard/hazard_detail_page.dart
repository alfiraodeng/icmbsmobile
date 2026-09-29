import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/hazard_tran_model.dart';
import '../../services/api.dart';
import '../../services/database.dart';
import '../../services/sync.dart';
import '../../utils/enums.dart';
import '../../utils/helpers.dart';
import '../../widgets/alert_app.dart';
import '../../widgets/button_app.dart';
import '../../widgets/snackbar_msg.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/upload_files.dart';

class HazardDetailPage extends StatefulWidget {
  const HazardDetailPage({this.hazardTrnModel, super.key});

  final HazardTrnModel? hazardTrnModel;

  @override
  State<HazardDetailPage> createState() => _HazardDetailPageState();
}

class _HazardDetailPageState extends State<HazardDetailPage> {
  final _scrollCtrl = ScrollController();
  final _db = DatabaseService();
  final _api = ApiService();
  final _remark = TextEditingController();
  final _remarkDone = TextEditingController();
  bool? _repair;
  String? _image;
  String? _imageDone;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _db.dropFiles('HazardDetail1');
      _db.dropFiles('HazardDetail2');
      _repair = false;
    });
  }

  @override
  void dispose() {
    /** */

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const TopBar(title: 'Hazard Report', back: 2),
        body: SingleChildScrollView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload Foto Temuan',
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
                            leading: const Icon(Icons.camera_alt,
                                color: Colors.grey),
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
                            leading:
                                const Icon(Icons.image, color: Colors.grey),
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
              if (_image != null) const UploadFiles('HazardDetail1', 0),
              const SizedBox(height: 15),
              const Text(
                'Keterangan Temuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _remark,
                minLines: 3,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 24,
                      color: Colors.indigo.shade400,
                    ),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (String val) => setState(() {}),
              ),
              Visibility(
                visible: _remark.text != '' ? true : false,
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    color: Colors.yellow.shade200,
                    shadowColor: Colors.transparent,
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Apakah temuan dapat diselesaikan saat ini?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _remark.text != '' ? true : false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Radio(
                        activeColor: Colors.green,
                        value: true,
                        groupValue: _repair,
                        onChanged: (value) {
                          setState(() => _repair = true);
                          Future.delayed(const Duration(milliseconds: 200), () {
                            _scrollCtrl.animateTo(
                              _scrollCtrl.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                      ),
                    ),
                    const Text('YA'),
                    const SizedBox(width: 50),
                    SizedBox(
                      width: 40,
                      child: Radio(
                        activeColor: Colors.red,
                        value: false,
                        groupValue: _repair,
                        onChanged: (value) {
                          setState(() => _repair = false);
                        },
                      ),
                    ),
                    const Text('TIDAK'),
                  ],
                ),
              ),
              Visibility(
                visible: _repair == true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Foto Perbaikan',
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
                                  leading: const Icon(Icons.camera_alt,
                                      color: Colors.grey),
                                  title: const Text('Camera'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Future<File?> imageFile =
                                        pickImage(source: ImageSource.camera);
                                    imageFile.then((value) {
                                      if (value != null) {
                                        setState(() => _imageDone = value.path);
                                      }
                                    });
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image,
                                      color: Colors.grey),
                                  title: const Text('Gallery'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Future<File?> imageFile =
                                        pickImage(source: ImageSource.gallery);
                                    imageFile.then((value) {
                                      if (value != null) {
                                        setState(() => _imageDone = value.path);
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
                        child: _imageDone == null || _imageDone == ''
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
                            : Image.file(File(_imageDone!)),
                      ),
                    ),
                    if (_image != null) const UploadFiles('HazardDetail2', 0),
                    const SizedBox(height: 15),
                    const Text(
                      'Keterangan Perbaikan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _remarkDone,
                      minLines: 3,
                      maxLines: 3,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.note_alt_outlined,
                            size: 24,
                            color: Colors.indigo.shade400,
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      onChanged: (String val) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: buttonApp(
            label: 'Simpan',
            onPressed: (_image == null ||
                    _remark.text == '' ||
                    (_repair == true &&
                        (_imageDone == null || _remarkDone.text == '')))
                ? null
                : () {
                    widget.hazardTrnModel?.createdAt =
                        DateTime.now().toString();
                    widget.hazardTrnModel?.updatedAt =
                        DateTime.now().toString();
                    widget.hazardTrnModel?.remark = _remark.text;
                    widget.hazardTrnModel?.repairRemark = _remarkDone.text;
                    widget.hazardTrnModel?.image = _image;
                    widget.hazardTrnModel?.repairImage = _imageDone;
                    widget.hazardTrnModel?.repair = (_repair == true) ? 1 : 0;
                    widget.hazardTrnModel?.status = (_repair == true) ? 1 : 0;
                    try {
                      _db
                          .insert(
                              'hazard_trans', widget.hazardTrnModel!.toJson())
                          .then((tranId) {
                        if (tranId > 0) {
                          syncTran(_db, _api, 'hazard', tranId).then((sync) {
                            if (sync == true) {
                              SnackBarMsg.success(context, 'Berhasil sinkron!');
                            } else {
                              SnackBarMsg.danger(context, 'Gagal sinkron!');
                            }
                          });
                          _db.saveFiles('HazardDetail1', 0, tranId, 0);
                          _db.saveFiles('HazardDetail2', 0, tranId, 0);
                          alertSuccess(context, Module.hazard, lastId: tranId);
                        } else {
                          alertFailed(context, Module.hazard);
                        }
                      });
                    } catch (e) {
                      debugPrint(e.toString());
                      alertFailed(context, Module.hazard);
                    }
                  },
          ),
        ),
      ),
    );
  }
}
