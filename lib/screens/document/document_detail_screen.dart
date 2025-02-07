import 'package:elderly_app/models/image.dart';
import 'package:elderly_app/widgets/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentDetail extends StatefulWidget {
  final ImageClass image;
  const DocumentDetail(this.image, {Key? key}) : super(key: key);

  @override
  _DocumentDetailState createState() => _DocumentDetailState();
}

class _DocumentDetailState extends State<DocumentDetail> {
  late ImageClass image;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    image = widget.image;
    initializeDownloader();
  }

  Future<void> initializeDownloader() async {
    // Initialization can be handled here if needed.
    // WidgetsFlutterBinding.ensureInitialized(); // Usually called in main().
  }

  Future<void> downloadDocument(String url) async {
    setState(() {
      isDownloading = true;
    });
    try {
      String? taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: '/storage/emulated/0/Documents',
        showNotification: true,
        openFileFromNotification: true,
      ).catchError((onError) {
        print(onError);
        setState(() {
          isDownloading = false;
        });
      });
      print(taskId);
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: image.name,
      child: Scaffold(
        appBar: const ElderlyAppBar(),
        drawer: const AppDrawer(),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Image.network(
                    image.url,
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height / 1.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                image.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            !isDownloading
                ? Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          bool permissionGranted = await checkPermission();
                          if (permissionGranted) {
                            await downloadDocument(image.url);
                          }
                          setState(() {
                            isDownloading = false;
                          });
                        },
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.green,
                          child: Center(
                            child: Icon(
                              Icons.file_download,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Download to Device'),
                      const SizedBox(height: 8),
                    ],
                  )
                : Column(
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
