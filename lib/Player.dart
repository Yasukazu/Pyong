import 'package:flutter/material.dart';
import 'package:pong/ball.dart';

enum players { SELF, ENEMY }

class PlayerColor {
  static Color get self => Colors.pink;
  static Color get enemy => Colors.purple;
}

// Player class
class Player {
  var x = -0.2; // starting horizontal position
  final double y;
  var score = 0;
  final Color color;
  var diff = 0.0; // keep lost ball reach
  static const FROMCENTER = 0.9;
  Player(this.y, this.color);
}

class SelfPlayer extends Player {
  SelfPlayer() : super(Player.FROMCENTER, PlayerColor.self);
}

class EnemyPlayer extends Player {
  EnemyPlayer() : super(-Player.FROMCENTER, PlayerColor.enemy);

  double calcBallArrivalFromCenter(BallPos bp) =>
      y * bp.dx / bp.dy;

  double calcBallArrivalFromAway(BallPos bp, 
      {centerToSideWall = 1.0}) {
    final a = bp.x + 2 * y * bp.dyx/ bp.dy;
    if (a <= centerToSideWall)
      return a;
    else {
      return 2 * centerToSideWall - a - bp.x;
    }
  }
}
