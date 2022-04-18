import 'package:flutter/material.dart';
import 'package:pong/ball.dart';
import 'package:pong/devHomePage.dart';
import 'package:pong/brick.dart';

enum players { SELF, ENEMY }

class PlayerColor {
  static Color get self => Colors.pink;
  static Color get enemy => Colors.purple;
}

// Player class
class Player {
  var x = -0.0; // starting horizontal position
  final double y;
  var score = 0;
  final Color color;
  final width;
  var diff = 0.0; // keep lost ball reach
  Player(this.y, this.color, this.width);
}

class SelfPlayer extends Player {
  SelfPlayer(double width) : super(PLAYERFROMCENTER, PlayerColor.self, width);
  bool hitBall(BallPos bp) {}
}

class EnemyPlayer extends Player {
  EnemyPlayer(double width) : super(-PLAYERFROMCENTER, PlayerColor.enemy, width);

  double calcBallArrivalFromCenter(BallPos bp) => y * bp.dx / bp.dy;

  double calcBallArrivalFromAway(BallPos bp, {centerToSideWall = 1.0}) {
    final a = bp.x + 2 * y * bp.dx / bp.dy;
    if (a <= centerToSideWall)
      return a;
    else {
      return 2 * centerToSideWall - a;
    }
  }

  double calcBallArrival2(BallPos bp) {
    assert(CENTERTOSIDE <= 1.0);
    assert(bp.toSide <= CENTERTOSIDE);
    final xs = bp.toSide - bp.x.abs();
    final ys = xs * (bp.dy / bp.dx).abs();
    assert(HOMETOAWAY <= 2.0);
    assert(bp.homeToAway <= HOMETOAWAY);
    final yss = bp.homeToAway - ys;
    final xss = yss * (bp.dx / bp.dy).abs();
    final naX = (bp.toSide - xss).abs();
    assert(naX <= CENTERTOSIDE);
    return bp.x.sign * naX;
  }

  double simulateBallArrival(BallPos bp, {centerToSideWall = 1.0}) {
    const m = 8;
    Bouncer bX = Bouncer(m * bp.dx, x: bp.x, wall: bp.bX.wall);
    Bouncer bY = Bouncer(m * bp.dy, x: bp.y, wall: bp.bY.wall);
    BallPos vp = BallPos.withBouncers(bX, bY);
    // const e = 0.05;
    while (vp.y > -vp.bY.wall) vp.step();
    return vp.x;
  }
}
