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
  double get toSide => bX.w; // side from home
  double get w => toSide; // side from home
  double get homeToAway => 2 * bY.w; // home from center
  double get h => homeToAway; // home from center
  final Bouncer bX;
  final Bouncer bY;

  BallPos(double dx, double dy,
      {xf = CENTERTOSIDE,
      yf = HOMETOAWAY / 2,
      x = Bouncer.XDFLT,
      y = Bouncer.XDFLT})
      : bX = FullBouncer(dx, wall: xf, x: x),
        bY = FullBouncer(dy, wall: yf, x: y);

  // angle[radian]
  BallPos.withAngleDivider(double angle, int divider, {xf = 1.0, yf = 1.0})
      : bY = FullBouncer(1 / divider, wall: yf),
        bX = FullBouncer(tan(angle) / divider, wall: xf);

  BallPos.withBouncers(Bouncer xB, Bouncer yB)
      : bY = yB,
        bX = xB;

  /// return: [x._neg, y._neg]
  StepResults step() {
    final x = bX.step();
    final y = bY.step();
    return StepResults(x, y);
  }

  /// jump to wall
  StepResults? jump() {
    final x = bX.jumpCount();
    final y = bY.jumpCount();
    final n = min(x, y);
    StepResults? sr;
    for (int i = 0; i < n; ++i) sr = step();
    return sr;
  }

  static arrivalXFromCenter(double ballAngle) => tan(ballAngle / 360 * 2 * pi);
}

enum stepResult { toPlus, toMinus, keep }

class StepResults {
  final stepResult x;
  final stepResult y;
  StepResults(this.x, this.y);
}

abstract class Bouncer {
  set x(v);
  double get x;
  double get d;
  double get w;
  bool get neg;
  set neg(v);
  static const XDFLT = 0.0;
  static const WDFLT = 1.0;
  stepResult step();

  /// count how many steps to jump (about)
  int jumpCount() => neg ? x ~/ d : (w - x) ~/ d;

  /// jump until direction change
  int jump() {
    int n = 0;
    while (step() == stepResult.keep) ++n;
    return n;
  }
}

// between -wall and wall bouncing number
class FullBouncer extends Bouncer {
  double _x;
  //double _d;
  final double _e;
  bool _neg;
  final double wall;
  set x(v) => _x = v;
  double get x => _x;
  double get d => _neg ? -_e : _e;
  double get w => wall;
  bool get neg => _neg;
  set neg(v) => _neg = v;

  /// wall > 0
  FullBouncer(d, {x = Bouncer.XDFLT, wall = Bouncer.WDFLT})
      : this._e = d.abs(),
        _neg = d < 0,
        _x = x,
        this.wall = wall;

  /// return: bounced ? _neg : null
  stepResult step() {
    final a = _x + d;
    if (a < -wall) {
      _x = -a - 2 * wall;
      _neg = false;
      return stepResult.toPlus;
    } else if (a > wall) {
      _x = 2 * wall - a;
      _neg = true;
      return stepResult.toMinus;
    }
    _x = a;
    return stepResult.keep;
  }
}

// between 0 and wall bouncing number
class HalfBouncer extends Bouncer {
  double _x;
  //double _d;
  final double _e;
  bool _neg;
  final double wall;
  set x(v) => _x = v;
  double get x => _x;
  double get d => _neg ? -_e : _e;
  double get w => wall;
  bool get neg => _neg;
  set neg(v) => _neg = v;

  /// wall > 0
  HalfBouncer(d, {x = Bouncer.XDFLT, wall = Bouncer.WDFLT})
      : this._e = d.abs(),
        _neg = d < 0,
        _x = x,
        this.wall = wall;

  /// return: bounced ? _neg : null
  stepResult step() {
    final a = _x + d;
    if (a < 0) {
      _x = -a;
      _neg = false;
      return stepResult.toPlus;
    } else if (a > wall) {
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