import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:comic_bin/components/currentPage.dart';
import 'package:localstorage/localstorage.dart';

class ComicPage extends StatefulWidget {
  final String selectedComic;
  final List<String> comicPages;
  ComicPage(this.selectedComic, this.comicPages);

  @override
  _ComicPageState createState() => _ComicPageState(selectedComic, comicPages);
}

class _ComicPageState extends State<ComicPage> with WidgetsBindingObserver {
  final LocalStorage storage = LocalStorage('recentHistory.json');
  _ComicPageState(this.selectedComic, this.comicPages);
  List<String> comicPages;
  String selectedComic;

  List<dynamic> recentHistory = [];
  int lastPage = 0;
  bool pageSnapping = true;
  bool scrollDirection = true;
  bool fitToHeight = true;
  final PageController controller = PageController(viewportFraction: 1);

  @override
  void initState() {
    loadLocalStorage();
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        print('Resumed: Loaded local storage');
        break;
      case AppLifecycleState.inactive:
        saveLocalStorage();
        print('Inactive: saved to local storage');
        break;
    }
  }

  void zoom() {
    setState(() {
      fitToHeight = !fitToHeight;
    });
  }

  void loadLocalStorage() async {
    await storage.ready;
    List decodedHistory = json.decode(storage.getItem('recentHistory').toString());
    for (var val in decodedHistory) {
      if (val['path'] == selectedComic) {
        print('MATCH MATCH MATCH MATCH !!!!');
        controller.jumpToPage(val['lastPage']);
      }
    }
    print('selectedComic is: $selectedComic');
    print('lastPage is: $lastPage');
  }

  void saveLocalStorage() async {
    await storage.ready;
    List decodedHistory = json.decode(storage.getItem('recentHistory').toString());
    decodedHistory.asMap().forEach((i, value) {
      if (value['path'] == selectedComic) {
        setState(() {
          decodedHistory[i]['lastPage'] = lastPage;
        });
        print('decodedHistory[i]: ');
        print(decodedHistory[i]);
        String encodedHistory = json.encode(decodedHistory);
        print('encodedHistory: ');
        print(encodedHistory);
        storage.setItem('recentHistory', encodedHistory);
        print(storage.getItem('recentHistory'));
      }
    });
  }

  _onPageViewChange(int page) {
    lastPage = page;
    print('last page is: $lastPage');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        saveLocalStorage();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 1,
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                saveLocalStorage();
                Navigator.pop(context);
              }),
          actions: [
            Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    pageSnapping = !pageSnapping;
                  });
                },
                icon: (pageSnapping == true)
                    ? Icon(
                        Icons.stop_circle_outlined,
                        semanticLabel: 'Set scrolling to snap to page',
                      )
                    : Icon(
                        Icons.play_circle_outline,
                        semanticLabel: 'Allow free scrolling',
                      ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    scrollDirection = !scrollDirection;
                  });
                },
                icon: (scrollDirection == true)
                    ? Icon(
                        Icons.swap_horiz_rounded,
                        semanticLabel: 'Scroll horizontally',
                      )
                    : Icon(
                        Icons.swap_vert_rounded,
                        semanticLabel: 'Scroll vertically',
                      ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: new PageView.builder(
            physics: BouncingScrollPhysics(parent: ClampingScrollPhysics()),
            scrollDirection: (scrollDirection == true) ? Axis.horizontal : Axis.vertical,
            controller: controller,
            onPageChanged: _onPageViewChange,
            pageSnapping: (pageSnapping == true) ? true : false,
            itemCount: comicPages.length, // Can be null
            itemBuilder: (page, index) {
              // index gives you current page position.
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    child: GestureDetector(
                      onDoubleTap: () {
                        zoom();
                      },
                      child: Image.memory(
                        base64Decode(comicPages[index]),
                        alignment: Alignment.center,
                        height: double.infinity,
                        fit: (fitToHeight == true) ? BoxFit.fitWidth : BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 18,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 12.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CurrentPage((index + 1), comicPages),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
