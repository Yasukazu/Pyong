import 'dart:math';
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
  static const fromCenter = 0.9;
  Player(this.y, this.color);
}

class SelfPlayer extends Player {
  SelfPlayer() : super(-Player.fromCenter, PlayerColor.self);
}

class EnemyPlayer extends Player {
  EnemyPlayer() : super(-Player.fromCenter, PlayerColor.enemy);

  double calcBallArrival(BallPos pos) => (pos.y == 0)
      ? Player.fromCenter / pos.dy * pos.dx
      : calcBallArrivalFromAway(pos.dx, pos.dy, pos.x);

  double arrivalFromCenter(double a) => tan(a);

  double calcBallArrivalFromAway(double dx, double dy, double x,
      {centerToSideWall: 1.0}) {
    final a = x + 2 * centerToSideWall * dx / dy;
    if (a <= centerToSideWall)
      return a;
    else {
      return 2 * centerToSideWall - a - x;
    }
  }
}
