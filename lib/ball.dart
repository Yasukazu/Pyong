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
  double get x => _bx.x;
  double get y => _by.x;
  double get dx => _bx.d;
  double get dy => _by.d;
  double get xf => _bx.fence;
  double get yf => _by.fence;
  final Bouncer _bx;
  final Bouncer _by;

  BallPos(double x, double y, {xf = 1.0, yf = 1.0})
      : _bx = Bouncer(x, fence: xf),
        _by = Bouncer(y, fence: yf);

  // angle[degree]
  BallPos.withAngleDivider(double angle, int divider, {xf = 1.0, yf = 1.0})
      : _by = Bouncer(1 / divider, fence: yf),
        _bx = Bouncer(tan(angle / 360 * 2 * pi) / divider, fence: xf);

  /// return: [x._neg, y._neg]
  List<bool?> step() {
    var x = _bx.step();
    var y = _by.step();
    return [x, y];
  }
}

// between -fence and fence bouncing number
class Bouncer {
  double _x;
  //double _d;
  final double e;
  bool _neg;
  final double fence;
  double get x => _x;
  double get d => _neg ? -e : e;

  /// fence > 0
  Bouncer(d, {x = 0.0, fence = 1})
      : this.e = d.abs(),
        _neg = d < 0,
        _x = x,
        this.fence = fence;

  /// return: bounced ? _neg : null
  bool? step() {
    final a = _x + d;
    if (a < -fence) {
      _x = -a - 2 * fence;
      _neg = false;
      return _neg;
    } else if (a > fence) {
      _x = 2 * fence - a;
      _neg = true;
      return _neg;
    }
    _x = a;
    return null;
  }
}
