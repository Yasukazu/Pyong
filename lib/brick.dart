import 'package:flutter/material.dart';
import 'package:pong/Player.dart';

class Brick extends StatelessWidget {
  final double x;
  final double _y;
  double get y => _y; //player.y;
  double get brickWidth => player.width;
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
          child: Stack(children: [
            Positioned.fill(child: Align(alignment:Alignment(x, y), child: Container(
            alignment: Alignment(x, y),
            color: color, // isEnemy ? PlayerColor.enemy : PlayerColor.self, //Colors.purple[500] : Colors.pink[300],
            height: 20,
            width: MediaQuery.of(context).size.width * brickWidth
          ),),),
          Positioned.fill(child: Align(alignment:Alignment(x, y), child: Container(
          alignment: Alignment(x, y),
          color: Colors.black, // isEnemy ? PlayerColor.enemy : PlayerColor.self, //Colors.purple[500] : Colors.pink[300],
          height: 10,
          width: MediaQuery.of(context).size.width * brickWidth / 4
      ),),),
        ])));
  }
}
