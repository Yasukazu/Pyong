import 'package:flutter/material.dart';

class Status extends StatelessWidget {
  static const POSITION = 0.95;
  final double enemyStatus;
  final double playerStatus;
  Status(
      this.enemyStatus,
      this.playerStatus,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          alignment: Alignment(0, -POSITION),
          child: Text(
            enemyStatus.toString(),
            style: TextStyle(color: Colors.white, fontSize: 10),
          )),
      Container(
          alignment: Alignment(0, POSITION),
          child: Text(
            playerStatus.toString(),
            style: TextStyle(color: Colors.white, fontSize: 10),
          )),
    ]);
  }
}
