import 'package:flutter/material.dart';
import 'package:pong/Player.dart';
import 'package:pong/devHomePage.dart';

class Paddle extends StatelessWidget {
  static const margin = 0.02;
  final double x;
  double get y => player.y;
  double get width => player.width;
  Color get color => player.color;
  final Player player;
  double get height => Player.toBackwall;

  Paddle(this.player, this.x);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    logger.finer("x:$x, y:$y");
    logger.finer("width:$width,height:$height");
    logger.finer("screen width:${size.width},screen height:${size.height}");
    return Container(
        alignment: Alignment(-CENTERTOSIDE, y),
        height: size.height * (height - margin),
        width: size.width,
        child: CustomPaint(
          painter: RectPainter(size, x, y, width, height, color),
        ));
  }
}

class RectPainter extends CustomPainter {
  final Color color;
  final Size size;
  final double _w;
  final double _h;
  final double _x;
  final double _y;
  double get x => (_x + offset) * size.width;
  double get y => (_y < 0) ? 0 : _y * size.height * 0.9;
  double get h => _h * size.height;
  double get w => _w * size.width;
  double get offset => 0.5 - _w / 2;
  RectPainter(this.size, this._x, this._y, this._w, this._h, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(x, y) & Size(w, h), paint);
    logger.fine("canvas.drawRect(offset($x, 0) & Size($w, $h) ");
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
