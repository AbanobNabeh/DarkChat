import 'dart:isolate';
import 'dart:ui';

import 'package:darkchat/constants/constants.dart';
import 'package:darkchat/model/messagemodel.dart';
import 'package:darkchat/view/widget/message_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PDFviewScreen extends StatefulWidget {
  DocumentModel document;
  PDFviewScreen(this.document);
  @override
  State<PDFviewScreen> createState() => _PDFviewScreenState(document);
}

class _PDFviewScreenState extends State<PDFviewScreen> {
  DocumentModel document;
  _PDFviewScreenState(this.document);
  PDFViewController? controller;
  int startpage = 0;
  int maxpage = 0;
  Future download(String url) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final basestorage = await getExternalStorageDirectory();
      await FlutterDownloader.enqueue(
          url: url, savedDir: basestorage!.path, fileName: document.name!);
    } else {
      print("None");
    }
  }

  ReceivePort _port = ReceivePort();
  String progessdownload = "0";
  @override
  void initState() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
  
    send!.send([id, status, progress]);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.name!),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Center(
              child: deftext(text: "$startpage/$maxpage", size: 12),
            ),
          )
        ],
      ),
      body: PDF(
              onPageChanged: (page, total) {
                setState(() {
                  startpage = page! + 1;
                  maxpage = total!;
                });
              },
              onViewCreated: (controller) {
                print("object ${controller.getCurrentPage()}");
              },
              onRender: (pages) {
                print("object 2 $pages");
              },
              onError: (error) {
                print(error.toString());
              },
              onPageError: (page, error) {
                print('$page: ${error.toString()}');
              },
              )
          .cachedFromUrl(
              placeholder: (progress) => Center(child: Text('$progress %')),
              errorWidget: (error) => Center(child: Text(error.toString())),
              "${document.link}"),
      floatingActionButton: FloatingActionButton(
        onPressed: () => download(document.link!),
        backgroundColor: defcolor,
        child: Icon(NIcons.download_cloud),
      ),
    );
  }
}
