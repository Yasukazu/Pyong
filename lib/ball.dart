import 'package:flutter/material.dart';

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

// keeps between -1 and 1
class BallPos {
  var _x = 0.0;
  final double dx;
  bool _xR = false;
  double get x => _x;
  var _y = 0.0;
  final double dy;
  bool _yR = false;
  double get y => _y;

  BallPos(this.dx, this.dy);

  void reverseX() => _xR = !_xR;

  void reverseY() => _yR = !_yR;

  void step() {
    var ax = _x + dx;
    if (ax > 1) {
      _x = 2 - ax; // 1 - (ax - 1);
      _xR = !_xR;
    } else if (ax < 1) {}
    _x += _xR ? -dx : dx;
    _y += _yR ? -dy : dy;
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
