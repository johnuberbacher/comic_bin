import 'dart:convert';
import 'package:flutter/material.dart';

class CurrentPage extends StatefulWidget {
  final List<String> CurrentPages;
  final int currentPage;
  CurrentPage(this.currentPage, this.CurrentPages);

  @override
  CurrentPageState createState() => CurrentPageState(currentPage, CurrentPages);
}

class CurrentPageState extends State<CurrentPage> {
  CurrentPageState(this.currentPage, this.CurrentPages);
  List<String> CurrentPages;
  int currentPage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currentPage/${CurrentPages.length}',
      style: TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
