import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pong/Player.dart';
import 'package:pong/devHomePage.dart';

class Paddle extends StatelessWidget {
  static const MGN = 0.02;
  final double _x;
  double get x => _x;
  double get y => player.y;
  double get w => _xRatio * player.width;
  Color get color => (_xRatio == 1) ? player.color : Colors.black;
  final Player player;
  double get h => _yRatio * Player.toBackwall;
  late final double _xRatio;
  late final double _yRatio;

  Paddle(this.player, this._x, [xRatio = 1.0, yRatio = 1.0]) {
    _xRatio = xRatio;
    _yRatio = yRatio;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    logger.finer("x:$x, y:$y");
    logger.finer("screen width:${size.width},screen height:${size.height}");
    return Container(
        alignment: Alignment(-CENTERTOSIDE, y),
        height: size.height * (h - MGN),
        width: size.width,
        child: Stack(children: [
          Positioned.fill(child: Align( alignment: Alignment.center,
            child: CustomPaint(
              painter: RectPainter(size, x, y, w, h, player.color),
            ),),),
          Positioned.fill(child: Align( alignment: Alignment.center,
            child: CustomPaint(
              painter: RectPainter(size, x, y, w, h, Colors.black, 1/4),
        ),),),
        ]));
  }
}

class RectPainter extends CustomPainter {
  final Size size;
  final double _x;
  final double _y;
  final _w;
  final _h;
  final Color color;
  final double ratio;
  double get x => (_x + 1.0) / 2;
  double get y => (_y + 1.0) / 2;
  double get w => _w * ratio;
  double get h => _h * ratio;
  double get offset => -0.5;
  RectPainter(this.size, this._x, this._y, this._w, this._h, this.color, [this.ratio = 1.0]);
  @override
  void paint(Canvas canvas, Size size) {
    final xL = size.width;
    final yL = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(x * xL, y * yL) & Size(w * xL, h * yL), paint);
    logger.fine("canvas.drawRect(offset($x, 0) & Size($w, $h) ");
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
