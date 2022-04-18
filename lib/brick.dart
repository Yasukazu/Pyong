import 'package:flutter/material.dart';

class Brick extends StatelessWidget {
  final double x;
  final double y;
  final double brickWidth;
  final Color color; //isEnemy;
  Brick(this.x, this.y, this.brickWidth, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment((2 * x + brickWidth) / (2 - brickWidth), y),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            alignment: Alignment(0, 0),
            color: color, // isEnemy ? PlayerColor.enemy : PlayerColor.self, //Colors.purple[500] : Colors.pink[300],
            height: 20,
            width: MediaQuery.of(context).size.width * brickWidth / 2,
          ),
        ));
  }
}
