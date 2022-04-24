import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pong/ball.dart';
import 'package:pong/brick.dart';
import 'package:pong/welcomeScreen.dart';
import 'package:pong/Player.dart';
import 'package:logging/logging.dart';
import 'package:tuple/tuple.dart';

final logger = Logger('devMainLogger');

class DevHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DevHomePageState();
}

enum direction { UP, DOWN, LEFT, RIGHT }

const CENTERTOSIDE = 1.0;
const PLAYERTOBACKWALL = 0.1;
const CENTERTOPLAYER = 1.0;
const PLAYERFROMCENTER = CENTERTOPLAYER - PLAYERTOBACKWALL;
const HOMETOAWAY = 2 * (CENTERTOPLAYER - PLAYERTOBACKWALL);

enum selfOrEnemyDied { selfDied, enemyDied }

class _DevHomePageState extends State<DevHomePage> {
  //LOGIC
  // common params:
  static const selfBrickWidth = 0.5;
  static const enemyBrickWidth = 0.2;
  final moveLR = 0.2; // move length of moveLeft and moveRight
  int awayToHomeTime = 1000; // miliseconds
  final timerRep = 20; // ms
  double get ballMoveD => timerRep / awayToHomeTime;
  final rand = Random(DateTime.now().millisecondsSinceEpoch);
  //player members for setState
  double playerX = 0;
  int playerScore = 0;
  final selfPlayer = SelfPlayer(selfBrickWidth);

  // enemy members for setState
  double enemyX = 0;
  int enemyScore = 0;
  final enemyPlayer = EnemyPlayer(enemyBrickWidth);

  //ball members for setState
  double ballX = 0;
  double ballY = 0;
  var ballPos = BallPos(0, 0);
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.RIGHT;
  var gameStarted = false;
  final angleGenerator = RandAngleIterator(14); // degree
  double generateAngle() {
    final anglePairList = [
      [1.7, 1],
      [1, 0.7]
    ];
    // final rand = new Random();
    final elem = rand.nextInt(1);
    final xy = anglePairList[elem];
    return atan2(
        xy[0] * (rand.nextBool() ? 1 : -1), xy[1] * (rand.nextBool() ? 1 : -1));
  }

  void resetPositions() {
    setState(() {
      playerX = selfPlayer.x = 0;
      enemyX = enemyPlayer.x = 0;
      ballX = 0;
      ballY = 0;
    });
  }

  /// try to find landing point; returns null if not found..
  /* double? calcLandingPos(BallPos bp) {
    BallPos vp = ballPos.clone();
    StepResults? srs;
    var limit = 10;
    do {
      srs = vp.jump();
      if (srs == null) return null;
    } while (srs.y == stepResult.keep && --limit > 0);
    if (limit == 0) return null;
    return vp.x;
  } */

  void startGame() {
    gameStarted = true;
    final int divider = awayToHomeTime ~/ timerRep; // divide to get an integer
    double angle = angleGenerator.current; // generateAngle();
    angleGenerator.moveNext();
    logger.info('angle: ${angle / pi * 180}');
    // degreeToRadian(40 + (startFromEnemy ? 180 : 0)); // radian from degree
    ballPos = BallPos.withAngleDivider(angle, divider, yf: PLAYERFROMCENTER);
    logger.info(
        'ballPos: x=${ballPos.x}, y=${ballPos.y}, dx=${ballPos.dx}, dy=${ballPos.dy}');
    var startBall = true;
    Tuple2<double, int> ballArrivalPosAndCount =
        ballPos.jumpDown(); // calcLandingPos(ballPos);
    double ballArrivalPos = ballArrivalPosAndCount.item1;
    // final ballArrivalPos = Player.calcBallArrivalPos(ballPos, gameStarted);
    if (ballArrivalPos != ballPos.x) {
      logger.info('ballArrivalPos 1st: $ballArrivalPos');
      if (ballPos.dy > 0) {
        setState(() {
          playerX = selfPlayer.x = ballArrivalPos;
        });
        logger.info('playerX 1st to: $ballArrivalPos');
      } else {
        setState(() {
          enemyX = enemyPlayer.x = ballArrivalPos;
        });
        logger.info('enemyX 1st to: $ballArrivalPos');
      }
    } else
      logger.warning('calcLandingPos returned null.');

    var vPos = enemyX;
    Tuple2<double, int> vPosAndCount = Tuple2(vPos, 0);
    double vInch = 0.0;
    int vCount = 0;
    Timer.periodic(Duration(milliseconds: timerRep), (timer) {
      final stepResults = ballPos.step();
      setState(() {
        // ball visual move
        ballX = ballPos.x;
        ballY = ballPos.y;
      });
      if (vCount > 0) {
        enemyPlayer.x += vInch;
        vCount--;
        setState(() {
          enemyX = enemyPlayer.x;
        });
      }
      if (!gameStarted) {
        timer.cancel();
        logger.info('timer.cancel');
      }
      switch (stepResults.y) {
        case stepResult.toMinus:
          logger.info("stepResult.toMinus.");
          assert(ballX == ballPos.x);
          var just = 0;
          if ((just = selfPlayer.catchBall(ballPos)) != 0) {
            logger.info('self catch ball: ${just < 0 ? 'under' : 'over'}');
            enemyPlayer.score++;
            setState(() {
              enemyScore = enemyPlayer.score;
            });
            timer.cancel();
            vCount = 0;
            vInch = 0;
            _showDialog(selfOrEnemyDied.selfDied);
          } else {
            vPosAndCount = ballPos.jumpDown();
            vPos = vPosAndCount.item1;
            if (vPos != ballPos.x) {
              logger.info('vPos($vPos) differs from enemyX($enemyX).');
              vCount = vPosAndCount.item2;
              vInch = (vPos - enemyX) / vCount;
            }
          }
          break;
        case stepResult.toPlus:
          logger.info("stepResult.toPlus.");
          var just = 0;
          if ((just = enemyPlayer.catchBall(ballPos)) != 0) {
            logger.info('enemy catch ball: ${just < 0 ? 'under' : 'over'}');
            selfPlayer.score++;
            setState(() {
              playerScore = selfPlayer.score;
            });
            timer.cancel();
            _showDialog(selfOrEnemyDied.enemyDied);
          } else {
            vCount = 0;
            vInch = 0;
          }
          /* else { 
            final vPos = ballPos.jumpDown();
            if (vPos != ballPos.x)
              setState(() {
                playerX = selfPlayer.x =
                    vPos; // Player.calcBallArrivalPos(ballPos, startBall);
                logger.info('playerX is set: $playerX');
              }); 
          } */
          break;
        default:
      }
      if (startBall) {
        startBall = false;
        logger.info('startBall is set false.');
      }
    });
  }

  bool isEnemyDead() {
    if (ballY <= -1) {
      return true;
    }
    return false;
  }

  moveEnemyTo(x) {
    setState(() {
      enemyPlayer.x = x;
    });
  }

  moveEnemy() {
    const k = 1.5;
    final lastPos = ballX;
    Future.delayed(Duration(milliseconds: 250), () {
      // delay on reaction
      setState(() {
        enemyPlayer.x = lastPos +
            (ballXDirection == direction.LEFT
                ? -(enemyPlayer.diff * k)
                : enemyPlayer.diff * k); // compensate delay
      });
    });
  }

  void _showDialog(selfOrEnemyDied selfOrEnemy) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            elevation: 0.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            backgroundColor: Colors.purple,
            title: Center(
              child: Text(
                selfOrEnemy == selfOrEnemyDied.enemyDied
                    ? "You win."
                    : "Opponent win.",
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                      padding: EdgeInsets.all(7),
                      color: Colors.purple[100],
                      child: Text(
                        "Play Again",
                        style: TextStyle(
                            color: selfOrEnemy == selfOrEnemyDied.enemyDied
                                ? Colors.pink[300]
                                : Colors.purple[000]),
                      )),
                ),
              )
            ],
          );
        });
  }

  void resetGame() {
    Navigator.pop(context);
    setState(() {
      gameStarted = true;
      ballX = 0;
      ballY = 0;
      playerX = selfPlayer.x = 0;
      enemyX = enemyPlayer.x = 0;
    });
    logger.info('resetGame');
  }

  bool isPlayerDead() {
    if (ballY >= 0.9) {
      return true;
    }
    return false;
  }

  void moveBall() {
    //vertical movement
    setState(() {
      if (ballYDirection == direction.DOWN) {
        ballY += ballMoveD;
      } else if (ballYDirection == direction.UP) {
        ballY -= ballMoveD;
      }
    });
    //horizontal movement
    setState(() {
      if (ballXDirection == direction.LEFT) {
        ballX -= ballMoveD;
      } else if (ballXDirection == direction.RIGHT) {
        ballX += ballMoveD;
      }
    });
  }

  void moveLeft() {
    if (!(selfPlayer.x - moveLR - selfPlayer.width / 2 < -1)) {
      selfPlayer.x -= moveLR;
    } else {
      selfPlayer.x = -1 + selfPlayer.width / 2;
    }
    setState(() {
      playerX = selfPlayer.x;
    });
  }

  void moveRight() {
    if (!(selfPlayer.x + moveLR + selfPlayer.width / 2 > 1)) {
      selfPlayer.x += moveLR;
    } else {
      selfPlayer.x = 1 - selfPlayer.width / 2;
    }
    setState(() {
      playerX = selfPlayer.x;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }
      },
      child: GestureDetector(
        onTap: startGame,
        child: Scaffold(
            backgroundColor: Colors.grey[900],
            body: Center(
                child: Stack(
              children: [
                Welcome(gameStarted),

                //enemy brick on top
                Brick(enemyPlayer, enemyX),
                //scoreboard
                Score(gameStarted, enemyScore, playerScore),
                // ball
                Ball(ballX, ballY),
                // self brick on bottom
                Brick(selfPlayer, playerX)
              ],
            ))),
      ),
    );
  }
}

class Score extends StatelessWidget {
  final bool gameStarted;
  final int enemyScore;
  final int playerScore;
  Score(
    this.gameStarted,
    this.enemyScore,
    this.playerScore,
  );

  @override
  Widget build(BuildContext context) {
    return gameStarted
        ? Stack(children: [
            Container(
                alignment: Alignment(0, 0),
                child: Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width / 3,
                  color: Colors.grey[800],
                )),
            Container(
                alignment: Alignment(0, -0.3),
                child: Text(
                  enemyScore.toString(),
                  style: TextStyle(color: Colors.grey[800], fontSize: 100),
                )),
            Container(
                alignment: Alignment(0, 0.3),
                child: Text(
                  playerScore.toString(),
                  style: TextStyle(color: Colors.grey[800], fontSize: 100),
                )),
          ])
        : Container();
  }
}

degreeToRadian(a) => a / 360 * 2 * pi;
