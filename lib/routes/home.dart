import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:comic_bin/routes/comic.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> comicPages = [];
  List<PlatformFile> recentHistory = [];
  bool loading = false;
  double loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadFile() async {
    // clear previously loaded file data
    comicPages = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['cbr', 'cbz', 'cbt', 'cba', 'cb7', 'zip', '7z', 'rar', 'tar', 'ace'],
    );
    if (result != null) {
      setState(() {
        loading = true;
      });
      PlatformFile file = result.files.first;
      if (await Permission.storage.request().isGranted) {
        final bytes = File(file.path.toString()).readAsBytesSync();
        setState(() {
          recentHistory.add(file);
          print('Recent History: ${recentHistory}');
        });
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            setState(() {
              comicPages.add(base64Encode(data));
              loading = false;
            });
          }
        }
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadRecentFile(file) async {
    // clear previously loaded file data
    comicPages = [];
    setState(() {
      loading = true;
    });
    if (await Permission.storage.request().isGranted) {
      final bytes = File(file.path.toString()).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          setState(() {
            comicPages.add(base64Encode(data));
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
          });
        }
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.only(
            top: 30,
            left: 30,
            right: 30,
            bottom: 20,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                      bottom: 30.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 15.0,
                          ),
                          child: Icon(
                            Icons.auto_stories_outlined,
                            color: Colors.blue,
                            size: 60.0,
                            semanticLabel:
                                'Upload a comic (supported file types: cbr, cbz, cbt, cba, cb7, zip, 7z, rar, tar, ace)',
                          ),
                        ),
                        Text(
                          "ComicBin",
                          style: TextStyle(
                              fontSize: 36, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        height: 300,
                        width: 300,
                        child: Material(
                          color: Colors.transparent,
                          child: new InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              loadFile().then((done) async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ComicPage(comicPages),
                                  ),
                                );
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(100)),
                                  margin: const EdgeInsets.only(
                                    bottom: 15.0,
                                  ),
                                  width: 125.0,
                                  height: 125.0,
                                  child: Icon(
                                    Icons.drive_folder_upload,
                                    color: Colors.blue,
                                    size: 75.0,
                                    semanticLabel:
                                        'Upload a comic (supported file types: cbr, cbz, cbt, cba, cb7, zip, 7z, rar, tar, ace)',
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  child: Text(
                                    "Upload a comic",
                                    style: TextStyle(
                                        fontSize: 26,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  "Supported file types: cbr, cbz, cbt, cba, cb7, zip, 7z, rar, tar, ace",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  (recentHistory.isEmpty)
                      ? Container()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Recent Files:",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height * 0.25,
                              ),
                              margin: const EdgeInsets.only(
                                top: 15.0,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: List.from(
                                    recentHistory.map((file) => Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 10.0,
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () async {
                                                loadRecentFile(file).then((done) async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ComicPage(comicPages),
                                                    ),
                                                  );
                                                });
                                              },
                                              borderRadius: BorderRadius.circular(15),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 25.0,
                                                ),
                                                child: Text(
                                                  file.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue,
                                                      fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
              loading
                  ? Positioned(
                      top: 0.0,
                      right: 0.0,
                      bottom: 0.0,
                      left: 0.0,
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.9),
                        child: Center(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 30.0,
                              ),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: new CircularProgressIndicator(
                                  strokeWidth: 5,
                                ),
                              ),
                            ),
                            Text(
                              "Loading",
                              style: TextStyle(
                                  fontSize: 26, color: Colors.blue, fontWeight: FontWeight.w600),
                            ),
                          ],
                        )),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
