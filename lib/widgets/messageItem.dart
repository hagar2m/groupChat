import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatdemo/screens/fullPhoto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';

import '../utils/colors.dart';

class MessageItem extends StatefulWidget {
  MessageItem({
    @required this.index,
    @required this.document,
    @required this.listMessage,
    @required this.currentUserId,
    @required this.flutterSound,
  });

  String currentUserId;
  var document;
  FlutterSound flutterSound;
  int index;
  List listMessage;

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  double maxDuration = 1.0;
  String playerTxt;
  double sliderCurrentPosition = 0.0;

  StreamSubscription _playerSubscription;

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            widget.listMessage != null &&
            widget.listMessage[index - 1]['idFrom'] !=
                widget.listMessage[index]['idFrom']) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // bool isLastMessageRight(int index) {
  //   if ((index > 0 &&
  //           widget.listMessage != null &&
  //           widget.listMessage[index - 1]['idFrom'] != widget.currentUserId) || index == 0) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
  bool _islastIndex(int index) {
    if (index > 0 &&
        (widget.listMessage[index - 1]['idFrom'] !=
            widget.listMessage[index]['idFrom'])) {
      return true;
    }
    return false;
  }

  void startPlayer(String recordUrl) async {
    print('startPlayer');

    try {
      String path =
          await widget.flutterSound.startPlayer(recordUrl); // From file

      if (path == null) {
        print('Error starting player');
        return;
      }
      print('startPlayer: $path');
      await widget.flutterSound.setVolume(1.0);

      _playerSubscription =
          widget.flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          sliderCurrentPosition = e.currentPosition;
          maxDuration = e.duration;

          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
          this.setState(() {
            this.playerTxt = txt.substring(0, 8);
          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
    // setState(() {});
  }

  void stopPlayer() async {
    try {
      String result = await widget.flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }
      this.setState(() {
        sliderCurrentPosition = 0.0;
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async {
    String result;
    try {
      if (widget.flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED) {
        result = await widget.flutterSound.resumePlayer();
        print('resumePlayer: $result');
      } else {
        result = await widget.flutterSound.pausePlayer();
        print('pausePlayer: $result');
      }
    } catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  void seekToPlayer(int milliSecs) async {
    String result = await widget.flutterSound.seekToPlayer(milliSecs);
    print('seekToPlayer: $result');
  }

  onPausePlayerPressed() {
    return widget.flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING ||
            widget.flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED
        ? pausePlayer
        : null;
  }

  onStopPlayerPressed() {
    return widget.flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING ||
            widget.flutterSound.audioState == t_AUDIO_STATE.IS_PAUSED
        ? stopPlayer
        : null;
  }

  onStartPlayerPressed(String voiceUrl) {
    if (voiceUrl == null) return null;
    return widget.flutterSound.audioState == t_AUDIO_STATE.IS_STOPPED
        ? startPlayer(voiceUrl)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: _islastIndex(widget.index) ? 20.0 : 10.0),
      child: _buildItem(),
    );
  }

  _buildItem() {
    if (widget.document['idFrom'] == widget.currentUserId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          // Text
          widget.document['type'] == 0
              ? _textWidget(color: textColor)
              : widget.document['type'] == 1
                  // Image
                  ? Container(
                      // margin: EdgeInsets.only(
                      //   bottom: isLastMessageRight(widget.index) ? 20.0 : 10.0,
                      //   right: 10.0
                      // ),
                      child: _imageWidget(),
                    )
                  // Sticker
                  : widget.document['type'] == 3
                      ? _voiceContainer(widget.document['content'])
                      : _stickerWidget(),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              isLastMessageLeft(widget.index)
                  ? _userPhoto()
                  : Container(width: 35.0),

              //  show text or image
              _showFriendContent(),
            ],
          ),
          // Time
          isLastMessageLeft(widget.index)
              ? Container(
                  // margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  child: Row(
                  children: <Widget>[
                    Text(
                      '${widget.document['nameFrom']}',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(widget.document['timestamp']))),
                      style: TextStyle(
                          color: textColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ))
              : Container()
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
  }

  _textWidget({Color color}) {
    return Flexible(
      child: Container(
        child: Text(
          '${widget.document['content']} ${widget.index}',
          style: TextStyle(color: Colors.white),
        ),
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        decoration: BoxDecoration(
            color: color ?? primaryColor,
            borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  _userPhoto() {
    return Container(
      margin: EdgeInsets.only(right: 8.0),
      child: Material(
        child: CachedNetworkImage(
          placeholder: (context, url) => Container(
            child: CircularProgressIndicator(
              strokeWidth: 1.0,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            width: 35.0,
            height: 35.0,
            padding: EdgeInsets.all(10.0),
          ),
          imageUrl: widget.document['photoFrom'],
          width: 35.0,
          height: 35.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
        clipBehavior: Clip.hardEdge,
      ),
    );
  }

  _imageWidget() {
    double _size = 170.0;
    return FlatButton(
      child: Material(
        child: CachedNetworkImage(
          placeholder: (context, url) => Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: textColor,
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Material(
            child: Image.asset(
              'images/img_not_available.jpeg',
              width: _size,
              height: _size,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
            clipBehavior: Clip.hardEdge,
          ),
          imageUrl: widget.document['content'],
          width: _size,
          height: _size,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        clipBehavior: Clip.hardEdge,
      ),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FullPhoto(url: widget.document['content'])));
      },
      padding: EdgeInsets.all(0),
    );
  }

  _showFriendContent() {
    // id to
    if (widget.document['type'] == 0) {
      // txt
      return _textWidget(color: primaryColor);
    } else if (widget.document['type'] == 1) {
      //img
      return _imageWidget();
    } else if (widget.document['type'] == 2) {
      // stickers
      return _stickerWidget();
    } else if (widget.document['type'] == 3) {
      // record
      return _voiceContainer(widget.document['content']);
    }
    return Container();
  }

  _stickerWidget() {
    return Container(
      child: Image.asset(
        'images/${widget.document['content']}.gif',
        width: 100.0,
        height: 100.0,
        fit: BoxFit.cover,
      ),
    );
  }

  _voiceContainer(String voiceUrl) {
    return Container(
      // height: 50.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: textColor,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(
                  widget.flutterSound.audioState == t_AUDIO_STATE.IS_PLAYING
                      ? Icons.stop
                      : Icons.play_arrow,
                  color: Colors.white),
              onPressed: () => onStartPlayerPressed(voiceUrl)),
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            child: Slider(
                value: sliderCurrentPosition,
                inactiveColor: thirdColor,
                min: 0.0,
                max: maxDuration,
                onChanged: (double value) async {
                  await widget.flutterSound.seekToPlayer(value.toInt());
                },
                divisions: maxDuration.toInt()),
          ),
        ],
      ),
    );
  }
}
