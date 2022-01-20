import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:comic_bin/routes/comic.dart';
import 'package:localstorage/localstorage.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalStorage storage = LocalStorage('recentHistory.json');
  List<String> comicPages = [];
  String selectedComic = '';
  List recentHistory = [];
  bool loading = false;
  int lastPage = 0;
  double loadingProgress = 0.0;

  @override
  void initState() {
    loadHistory();
    super.initState();
  }

  Future<void> loadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'cbr',
        'cbz',
        'cbt',
        'cba',
        'cb7',
        'zip',
        '7z',
        'rar',
        'tar',
        'ace',
        'pdf'
      ],
    );
    if (result != null) {
      setState(() {
        loading = true;
        comicPages = [];
      });
      await Future.delayed(Duration(seconds: 1));
      PlatformFile file = result.files.first;
      if (await Permission.storage.request().isGranted) {
        decodeFile(file);
        var insertSelectedFileMap = {
          'path': file.path.toString(),
          'name': file.name.toString(),
          'lastPage': 0,
          'pageCount': comicPages.length,
        };
        await storage.ready;
        if (storage.getItem('recentHistory') != null) {
          recentHistory = json.decode(storage.getItem('recentHistory').toString());
          var snapshotHistory = recentHistory.toList();
          snapshotHistory.asMap().forEach((i, value) {
            print('here!!!');
            if (value['path'].toString() != file.path.toString()) {
              print('this is a new file');
              setState(() {
                recentHistory.add(insertSelectedFileMap);
                storage.setItem('recentHistory', json.encode(recentHistory));
              });
            } else {
              print('this file has been uploaded already');
              print('''
            ${value['path']} - ${file.path.toString()}
          ''');
            }
          });
        } else {
          setState(() {
            recentHistory.add(insertSelectedFileMap);
            storage.setItem('recentHistory', json.encode(recentHistory));
          });
        }
        setState(() {
          selectedComic = file.path.toString();
          loading = false;
        });
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => ComicPage(selectedComic, comicPages)))
            .then((value) {
          loadHistory();
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> loadRecentFile(file) async {
    setState(() {
      loading = true;
      comicPages = [];
    });
    await Future.delayed(Duration(seconds: 1));
    if (await Permission.storage.request().isGranted) {
      await storage.ready;
      decodeFile(file);
      setState(() {
        selectedComic = file.path.toString();
        loading = false;
      });
      Navigator.push(context,
              MaterialPageRoute(builder: (context) => ComicPage(selectedComic, comicPages)))
          .then((value) {
        loadHistory();
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  decodeFile(file) {
    final bytes = File(file.path.toString()).readAsBytesSync();
    print('hereeee');
    Archive archive = TarDecoder().decodeBytes(bytes);
    print('hereeee2222');
    List<String> supportedFileTypes = [
      "image/bmp",
      "image/gif",
      "image/jpeg",
      "image/pipeg",
      "image/png",
      "image/tiff",
      "image/webp",
      "application/pdf",
      "application/x-cbr",
      "application/vnd.comicbook+zip",
      "application/vnd.comicbook-rar"
    ];
    print('starting loop');
    for (ArchiveFile compressedFile in archive) {
      print('checking if file');
      if (compressedFile.isFile) {
        print(lookupMimeType(file.path.toString()));
        if (supportedFileTypes.contains(lookupMimeType(file.path.toString()))) {
          final data = compressedFile.content as List<int>;
          setState(() {
            comicPages.add(base64Encode(data));
          });
        }
      }
    }
  }

  loadHistory() async {
    await storage.ready;
    if (storage.getItem('recentHistory') != null) {
      setState(() {
        recentHistory = json.decode(storage.getItem('recentHistory').toString());
      });
    }
  }

  recentFiles() {
    if (recentHistory.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Recent Files:",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.2,
            ),
            margin: const EdgeInsets.only(
              top: 10.0,
            ),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(parent: ClampingScrollPhysics()),
              scrollDirection: Axis.vertical,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: recentHistory
                      .map((item) => new Container(
                            margin: const EdgeInsets.only(
                              bottom: 20.0,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  File(item['path']).exists();
                                  File recentFile = new File(item['path']);
                                  loadRecentFile(recentFile);
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                    horizontal: 25.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['name'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 15.0,
                                        ),
                                        child: Text(
                                          '${(item['lastPage'] + 1)}/${item['pageCount']}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList()),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      top: 30,
                      left: 20,
                      right: 20,
                      bottom: 0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 60.0,
                                  semanticLabel:
                                      'Upload a comic (supported file types: cbr, cbz, cbt, cba, cb7, zip, 7z, rar, tar, ace, pdf)',
                                ),
                              ),
                              Text(
                                "ComicBin",
                                style: Theme.of(context).textTheme.headline1,
                              ),
                            ],
                          ),
                        ),
                        Center(
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
                                  loadFile();
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.secondary,
                                          borderRadius: BorderRadius.circular(100)),
                                      margin: const EdgeInsets.only(
                                        bottom: 15.0,
                                      ),
                                      width: 125.0,
                                      height: 125.0,
                                      child: Icon(
                                        Icons.drive_folder_upload,
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 75.0,
                                        semanticLabel:
                                            'Upload a comic (supported file types: cbr, cbz, cbt, cba, cb7, zip, 7z, rar, tar, ace, pdf)',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20.0,
                                      ),
                                      child: Text(
                                        "Upload a comic",
                                        style: Theme.of(context).textTheme.headline2,
                                      ),
                                    ),
                                    Text(
                                      "Supported file types: cbr, cbz, cbt, cba, cb7, zip, 7z, rar, tar, ace, pdf",
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        recentFiles(),
                      ],
                    ),
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
                            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.auto_stories_outlined,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 100.0,
                                    semanticLabel:
                                        'Upload a comic (supported file types: cbr, cbz, cbt, cba, cb7, zip, 7z, rar, tar, ace, pdf)',
                                  ),
                                  Text(
                                    "Loading",
                                    style: Theme.of(context).textTheme.headline2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Positioned(
                          child: Container(),
                        ),
                ],
              ),
            ),
          )),
    );
  }
}
