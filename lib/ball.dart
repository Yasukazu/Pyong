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

class BallPos {
  var _x = 0.0;
  final dx;
  bool _xR = false;
  double get x => _x;
  var _y = 0.0;
  final dy;
  bool _yR = false;
  double get y => _y;

  BallPos(this.dx, this.dy);

  void reverseX() => _xR = !_xR;

  void reverseY() => _yR = !_yR;

  void step() {
    _x += _xR ? -dx : dx;
    _y += _yR ? -dy : dy;
  }
}
