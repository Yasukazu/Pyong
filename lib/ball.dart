import 'package:flutter/material.dart';
import 'dart:math';

class Ball extends StatelessWidget {
  final x;
  final y;
  Ball(this.x, this.y);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(x, y),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        width: 20,
        height: 20,
      ),
    );
  }
}

// x and y both keep between -1 and 1
class BallPos {
  double get x => _bX.x;
  double get y => _bY.x;
  double get dx => _bX.d;
  double get dy => _bY.d;
  // double get xf => _bX.wall;
  // double get yf => _bY.wall;
  final Bouncer _bX;
  final Bouncer _bY;

  BallPos(double x, double y, {xf = 1.0, yf = 1.0})
      : _bX = Bouncer(x, wall: xf),
        _bY = Bouncer(y, wall: yf);

  // angle[radian]
  BallPos.withAngleDivider(double angle, int divider, {xf = 1.0, yf = 1.0})
      : _bY = Bouncer(1 / divider, wall: yf),
        _bX = Bouncer(tan(angle) / divider, wall: xf);

  /// return: [x._neg, y._neg]
  List<stepResult> step() {
    var x = _bX.step();
    var y = _bY.step();
    return [x, y];
  }

  static arrivalXFromCenter(double ballAngle) => tan(ballAngle / 360 * 2 * pi);

  static arrivalXFromAway(double ballAngle) {}
}
  enum stepResult {
    bounceUp,
    bounceDown,
    noBounce
  }
// between -wall and wall bouncing number
class Bouncer {
  double _x;
  //double _d;
  final double e;
  bool _neg;
  final double wall;
  double get x => _x;
  double get d => _neg ? -e : e;



  /// wall > 0
  Bouncer(d, {x = 0.0, wall = 1})
      : this.e = d.abs(),
        _neg = d < 0,
        _x = x,
        this.wall = wall;

  /// return: bounced ? _neg : null
  stepResult step() {
    final a = _x + d;
    if (a <= -wall) {
      _x = -a - 2 * wall;
      _neg = false;
      return stepResult.bounceUp;
    } else if (a >= wall) {
      _x = 2 * wall - a;
      _neg = true;
      return stepResult.bounceDown;
    }
    _x = a;
    return stepResult.noBounce;
  }
}

// extention AngleConversion on double { double degreeToRadian() => tan(this / 360 * 2 * pi); }