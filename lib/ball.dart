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
  final Bouncer _bx;
  final Bouncer _by;

  BallPos(double x, double y)
      : _bx = Bouncer(x),
        _by = Bouncer(y);

  // angle[degree]
  BallPos.withAngleDivider(double angle, int divider)
      : _by = Bouncer(1 / divider),
        _bx = Bouncer(tan(angle / 360 * 2 * 3.14) / divider);

  /// return: [x, y]
  List<double> step() {
    _bx.step();
    _by.step();
    return [x, y];
  }
}

// between -1 and 1 bouncing number
class Bouncer {
  var _x = 0.0;
  double _d;
  double get x => _x;
  double get d => _d;

  Bouncer(this._d);

  /// return: step amount (inc/dec)
  double step() {
    var oldX = _x;
    var a = _x + _d;
    if (a < -1) {
      _x = -a - 2;
      _d = -_d;
    } else if (a > 1) {
      _x = 2 - a;
      _d = -_d;
    } else {
      _x = a;
    }
    return _x - oldX;
  }
}
