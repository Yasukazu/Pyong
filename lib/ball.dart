import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pong/devHomePage.dart';

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
  double get x => bX.x;
  double get y => bY.x;
  double get dx => bX.d;
  double get dy => bY.d;
  double get toSide => bX.wall; // side from home
  double get homeToAway => 2 * bY.wall; // home from center
  final Bouncer bX;
  final Bouncer bY;

  BallPos(double dx, double dy, {xf = CENTERTOSIDE, yf = HOMETOAWAY / 2})
      : bX = Bouncer(dx, wall: xf),
        bY = Bouncer(dy, wall: yf);

  // angle[radian]
  BallPos.withAngleDivider(double angle, int divider, {xf = 1.0, yf = 1.0})
      : bY = Bouncer(1 / divider, wall: yf),
        bX = Bouncer(tan(angle) / divider, wall: xf);

  BallPos.withBouncers(Bouncer xB, Bouncer yB)
      : bY = yB,
        bX = xB;

  /// return: [x._neg, y._neg]
  StepResults step() {
    var x = bX.step();
    var y = bY.step();
    return StepResults(x, y);
  }

  static arrivalXFromCenter(double ballAngle) => tan(ballAngle / 360 * 2 * pi);

  static arrivalXFromAway(double ballAngle) {}
}

enum stepResult { toPlus, toMinus, keep }

class StepResults {
  final stepResult x;
  final stepResult y;
  StepResults(this.x, this.y);
}

// between -wall and wall bouncing number
class Bouncer {
  double _x;
  //double _d;
  final double _e;
  bool _neg;
  final double wall;
  double get x => _x;
  double get d => _neg ? -_e : _e;

  /// wall > 0
  Bouncer(d, {x = 0.0, wall = 1})
      : this._e = d.abs(),
        _neg = d < 0,
        _x = x,
        this.wall = wall;

  /// return: bounced ? _neg : null
  stepResult step() {
    final a = _x + d;
    if (a <= -wall) {
      _x = -a - 2 * wall;
      _neg = false;
      return stepResult.toPlus;
    } else if (a >= wall) {
      _x = 2 * wall - a;
      _neg = true;
      return stepResult.toMinus;
    }
    _x = a;
    return stepResult.keep;
  }
}

class RandAngleIterator extends Iterable with Iterator {
  final int range;
  final rand = new Random(new DateTime.now().millisecondsSinceEpoch);
  var _e = 0;
  var _s = false;
  int get v => (30 + _e) * (_s ? 1 : -1);

  RandAngleIterator(this.range) {
    _e = rand.nextInt(range);
    _s = rand.nextBool();
  }

  @override
  double get current => v / 180 * pi;

  @override
  bool moveNext() {
    _e = rand.nextInt(range);
    _s = rand.nextBool();
    return true;
  }

  @override
  Iterator get iterator => this;
}
// extention AngleConversion on double { double degreeToRadian() => tan(this / 360 * 2 * pi); }