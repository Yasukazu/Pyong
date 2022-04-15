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
  double get x => _dx.x;
  double get y => _dy.x;
  final Bouncer _dx;
  final Bouncer _dy;

  BallPos(double x, double y) :
    _dx = Bouncer(x),
    _dy = Bouncer(y);

  // angle[degree]
  BallPos.withAngleDivider(double angle, int divider) :
    _dy = Bouncer(1 / divider), 
    _dx = Bouncer(tan(angle / 360 * 2 * 3.14) / divider)
  ;
  
  void step() {
    _dx.step();
    _dy.step();
  }
}

// between -1 and 1 bouncing number
class Bouncer {
  var _x = 0.0;
  double _d;
  double get x => _x;

  Bouncer(this._d);

  void step() {
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
  }
}
