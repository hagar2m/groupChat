import 'package:flutter/material.dart';
import '../utils/colors.dart';

class LoadingStack extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  LoadingStack({@required this.child, @required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        // Loading
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(primaryColor)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : SizedBox(),
        )
      ],
    );
  }
}
