import 'package:flutter/material.dart';
import 'package:pong/ball.dart';
import 'package:pong/devHomePage.dart';

enum players { SELF, ENEMY }

class PlayerColor {
  static Color get self => Colors.pink;
  static Color get enemy => Colors.purple;
}

// Player class
class Player {
  var _x = 0.0; // starting horizontal position
  double get x => _x;
  set x(double d) {
    if (d < -CENTERTOSIDE)
      _x = -CENTERTOSIDE;
    else if (d > CENTERTOSIDE)
      _x = CENTERTOSIDE;
    else
      _x = d;
  }

  static const toBackwall = PLAYERTOBACKWALL;
  final double y;
  var score = 0;
  final Color color;
  final double width;
  var diff = 0.0; // keep lost ball reach
  Player(this.y, this.color, this.width);

  int catchBall(BallPos bp) {
    final over = bp.x > (x + width / 2);
    if (over) return 1;
    final under = bp.x < (x - width / 2);
    if (under) return -1;
    return 0;
  }

  static double _calcBallArrivalPos2(x, dx, dy, side, away, {depth = 0}) {
    if (depth > 2) throw Exception('Recursive call more than twice!');
    final a = x + away * dx / dy;
    if (a > 0 && a < side) return a;
    final yL = (side - x) * dy / dx;
    final nAway = away - yL;
    logger.info(
        'call _calcBallArrivalPos2 with ($side, ${-dx}, $dy, $side, $nAway, ${depth + 1}.');
    return _calcBallArrivalPos2(side, -dx, dy, side, nAway, depth: depth + 1);
  }

  static double calcBallArrivalPos(BallPos bp, bool isStart) {
    if (bp.dy > 0) {
      // calc for self player
      logger.info(
          'call _calcBallArrivalPos2 with (${bp.x + bp.toSide}, ${bp.dx}, ${bp.dy}, .. ');
      return _calcBallArrivalPos2(bp.x + bp.toSide, bp.dx, bp.dy, 2 * bp.toSide,
          isStart ? bp.homeToAway / 2 : bp.homeToAway);
    } else {
      logger.info(
          'call _calcBallArrivalPos2 with (${bp.x + bp.toSide}, ${bp.dx}, ${-bp.dy}, .. ');
      return _calcBallArrivalPos2(bp.x + bp.toSide, bp.dx, -bp.dy,
          2 * bp.toSide, isStart ? bp.homeToAway / 2 : bp.homeToAway);
    }
  }

  /*
    final xL = away * bp.dx / bp.dy;
    final aL = bp.x + xL;
    if (aL >= -bp.w && aL <= bp.w) {
      logger.info('Return $aL as ball arrival position.');
      return aL;
    }
    final b = bp.w - bp.x.abs();
    assert(b > 0);
    final h = (b * bp.dy / bp.dx).abs();
    final nY = (bp.dy < 0) ? -h : h;
    final nX = aL < -bp.w ? -bp.w : bp.w;
    final nBp = BallPos(-bp.dx, bp.dy, x: nX, y: nY);
    final yL = (xL * bp.dy / bp.dx).abs();
    final nAway = away - yL;
    logger.info(
        'Call recursively calcBallArrivalPos with BallPos(${-bp.dx}, ${bp.dy}, $nX, $nY) and away=$nAway.');
    return calcBallArrivalPos(nBp, away: nAway); */
}

class SelfPlayer extends Player {
  SelfPlayer(double width) : super(PLAYERFROMCENTER, PlayerColor.self, width);
}

class EnemyPlayer extends Player {
  EnemyPlayer(double width)
      : super(-PLAYERFROMCENTER, PlayerColor.enemy, width);

  double calcBallArrivalFromCenter(BallPos bp) => y * bp.dx / bp.dy;

  double calcBallArrival2(BallPos bp) {
    assert(CENTERTOSIDE <= 1.0);
    assert(bp.toSide <= CENTERTOSIDE);
    final xs = bp.toSide - bp.x.abs();
    final ys = xs * (bp.dy / bp.dx).abs();
    assert(HOMETOAWAY <= 2.0);
    assert(bp.homeToAway <= HOMETOAWAY);
    final yss = bp.homeToAway - ys;
    final xss = yss * (bp.dx / bp.dy).abs();
    final naX = (bp.toSide - xss).abs();
    assert(naX <= CENTERTOSIDE);
    return bp.x.sign * naX;
  }

  /*
  double simulateBallArrival(BallPos bp, {centerToSideWall = 1.0}) {
    const m = 2;
    Bouncer bX = Bouncer(m * bp.dx, x: bp.x, wall: bp.bX.wall);
    Bouncer bY = Bouncer(m * bp.dy, x: bp.y, wall: bp.bY.wall);
    BallPos vp = BallPos.withBouncers(bX, bY);
    // const e = 0.05;
    var x = 0.0;
    while (vp.y > -vp.bY.wall) {
      vp.step();
      x = vp.x;
      print('simulate x = $x');
      assert(x <= bp.bX.wall);
    }
    return x;
  } */
}
