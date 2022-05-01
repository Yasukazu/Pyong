import 'package:flutter/material.dart';
import 'package:pong/Player.dart';

class Brick extends StatelessWidget {
  final double x;
  final double _y;
  double get y => _y; //player.y;
  double get brickWidth => player.width; // ratio to screen
  Color get color => player.color;
  final Player player;
  Brick(this.player, this.x, this._y);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(x, y), // - brickWidth / 2 + x, y),
            //(2 * x + brickWidth) / (2 - brickWidth), y),
            child: ClipRect(
          // center: Offset(x - brickWidth / 2, 0),
          // borderRadius: BorderRadius.circular(10),
          child: Stack( alignment: AlignmentDirectional.center, children: [
          Container(
            color: color, // isEnemy ? PlayerColor.enemy : PlayerColor.self, //Colors.purple[500] : Colors.pink[300],
            height: 20,
            width: MediaQuery.of(context).size.width * brickWidth
          ),
          Container(
          color: Colors.black, // isEnemy ? PlayerColor.enemy : PlayerColor.self, //Colors.purple[500] : Colors.pink[300],
          height: 10,
          width: MediaQuery.of(context).size.width * brickWidth / 4
      ),
        ])));
  }
}
