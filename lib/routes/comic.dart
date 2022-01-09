import 'dart:convert';
import 'package:flutter/material.dart';

class ComicPage extends StatefulWidget {
  final List<String> comicPages;
  ComicPage(this.comicPages);

  @override
  _ComicPageState createState() => _ComicPageState(comicPages);
}

class _ComicPageState extends State<ComicPage> {
  _ComicPageState(this.comicPages);
  List<String> comicPages;
  bool fitToHeight = true;
  @override
  void initState() {
    print('comicPages is: ');
    print(comicPages);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                fitToHeight = !fitToHeight;
              });
            },
            icon: Icon(
              Icons.open_in_full_rounded,
              semanticLabel: 'Enlarge comic to fullscreen',
            ),
          )
        ],
      ),
      body: SafeArea(
        top: (fitToHeight == true) ? true : false,
        bottom: (fitToHeight == true) ? true : false,
        child: PageView(
          scrollDirection: Axis.horizontal,
          controller: controller,
          children: List.from(
            comicPages.map(
              (index) => Center(
                child: Padding(
                  padding: (fitToHeight == true)
                      ? EdgeInsets.only(
                          bottom: AppBar().preferredSize.height,
                        )
                      : EdgeInsets.only(
                          bottom: 0,
                        ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: InteractiveViewer(
                      panEnabled: true, // Set it to false to prevent panning.
                      boundaryMargin: EdgeInsets.all(0.0),
                      minScale: 1,
                      maxScale: 5,
                      child: Image.memory(
                        base64Decode(index),
                        alignment: Alignment.center,
                        height: double.infinity,
                        width: double.infinity,
                        fit: (fitToHeight == true)
                            ? BoxFit.fitWidth
                            : BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
