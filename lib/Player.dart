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

  double calcBallArrivalFromCenter(BallPos bp) => y * bp.dx / bp.dy;

  double calcBallArrivalFromAway(BallPos bp, {centerToSideWall = 1.0}) {
    final a = bp.x + 2 * y * bp.dx / bp.dy;
    if (a <= centerToSideWall)
      return a;
    else {
      return 2 * centerToSideWall - a;
    }
  }

  double simulateBallArrival(BallPos bp, {centerToSideWall = 1.0}) {
    Bouncer bX = Bouncer(bp.dx, x: bp.x, wall: bp.bX.wall);
    Bouncer bY = Bouncer(bp.dy, x: bp.y, wall: bp.bY.wall);
    BallPos vp = BallPos.withBouncers(bX, bY);
    const e = 0.05;
    while (vp.y > -vp.bY.wall + e) vp.step();
    return vp.x;
  }
}
