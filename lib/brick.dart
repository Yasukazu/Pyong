import 'package:flutter/material.dart';
import 'package:pong/Player.dart';

class Brick extends StatelessWidget {
  final double x;
  double get y => player.y;
  double get brickWidth => player.width;
  Color get color => player.color;
  final Player player;
  Brick(this.player, this.x);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment((2 * x + brickWidth) / (2 - brickWidth), y),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            alignment: Alignment(0, 0),
            color:
                color, // isEnemy ? PlayerColor.enemy : PlayerColor.self, //Colors.purple[500] : Colors.pink[300],
            height: 20,
            width: MediaQuery.of(context).size.width * brickWidth / 2,
          ),
        ));
  }
}
