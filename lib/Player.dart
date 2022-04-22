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

  final double y;
  var score = 0;
  final Color color;
  final width;
  var diff = 0.0; // keep lost ball reach
  Player(this.y, this.color, this.width);
  bool catchBall(BallPos bp) {
    final result = bp.x >= x - width / 2 && bp.x <= x + width / 2;
    print('in Player.catchBall: result = $result');
    return result;
  }

  /* double estimateArrivingPos(x, y, dx, dy) {
    assert(dy < 0);
    BallPos iP = BallPos.withBouncers(HalfBouncer(dx, x: x + 1, wall: 2 * bX.w),
        HalfBouncer(dy, x: y + 1, wall: 2 * bY.w));
    var xd = dx / dy * (2 - x);
  } */

  static double calcBallArrivalPos(BallPos bp, {centerToSideWall = 1.0}) {
    final away = bp.dy > 0 ? -HOMETOAWAY / 2 : HOMETOAWAY / 2;
    final yL = (away - bp.y).abs();
    final xL = (yL * bp.dx / bp.dy).abs();
    final aL = bp.x + xL * (bp.dx < 0 ? -1 : 1);
    assert(bp.w > 0);
    if (aL >= -bp.w && aL <= bp.w) {
      logger.info('Return $aL as ball arrival position.');
      return aL;
    }
    final b = bp.w - bp.x.abs();
    assert(b > 0);
    final h = (b * bp.dy / bp.dx).abs();
    final nY = bp.y + ((bp.dy < 0) ? -h : h);
    final nX = aL < -bp.w ? -bp.w : bp.w;
    final nBp = BallPos(-bp.dx, bp.dy, x: nX, y: nY);
    logger.info(
        'Call recursively calcBallArrivalPos with BallPos(${-bp.dx}, ${bp.dy}, $nX, $nY).');
    return calcBallArrivalPos(nBp);
  }
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
