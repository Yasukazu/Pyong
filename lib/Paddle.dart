import 'package:flutter/material.dart';
import 'package:pong/Player.dart';
import 'package:pong/devHomePage.dart';

class Paddle extends StatelessWidget {
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
    logger.finer("swidth:${size.width},sheight:${size.height}");
    return Container(
        alignment: Alignment(6.8, y),
        height: size.height * height,
        width: size.width * width,
        child: CustomPaint(
          painter: RectPainter(size, x, width, height, color),
        ));
  }
}

class RectPainter extends CustomPainter {
  final Color color;
  final double _w;
  final double _h;
  final Size size;
  final double _x;
  double get w => size.width * _w;
  double get h => size.height * _h;
  double get x => _x * size.width;
  RectPainter(this.size, this._x, this._w, this._h, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset(x, 0) & Size(w, h), paint);
    logger.fine("canvas.drawRect(offset($x, 0) & Size($w, $h) ");
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
