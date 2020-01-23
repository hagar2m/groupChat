import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  final String payload;
  TestScreen(this.payload);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String name;
  String msg;
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text("name - ${widget.payload['title']}"),
            Text('${widget.payload}'),

          ],
        )
      ),
    );
  }
}