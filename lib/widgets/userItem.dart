import 'package:chatdemo/utils/colors.dart';
import 'package:chatdemo/widgets/imageAvatar.dart';
import 'package:flutter/material.dart';
import '../models/userModel.dart';

class UserItem extends StatelessWidget {
  final Function onPressed;
  final UserModel user;
  const UserItem({
   this.onPressed,
   this.user
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: Row(
          children: <Widget>[
            ImageAvatar(imgUrl: user.photoUrl),
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${user.nickname}',
                        style: TextStyle(color: textColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    ),
                    user.aboutMe != null? Container(
                      child: Text(
                        'About me: ${user.aboutMe}',
                        style: TextStyle(color: textColor),
                      ),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                    ) : SizedBox()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
