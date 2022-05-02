import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
 
  final bool gameStarted;
  Welcome(this.gameStarted);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(0, -0.2),
        child: Text(
         gameStarted ? "": "<< Tap to play >>",
          style: TextStyle(color: Colors.white),
        ));
  }
}
