import 'package:flutter/material.dart';

class StickerImage extends StatelessWidget {
  final String name;
  final Function onSend;

  StickerImage({this.name, this.onSend});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () => this.onSend(content: name, type: 2),
      child: new Image.asset(
        'images/$name.gif',
        width: 50.0,
        height: 50.0,
        fit: BoxFit.cover,
      ),
    );
  }
}