import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:tuple/tuple.dart';
import 'package:pong/ball.dart';
import 'package:pong/welcomeScreen.dart';
import 'package:pong/Player.dart';
import 'package:pong/brick.dart';

final logger = Logger('devMainLogger');

class DevHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DevHomePageState();
}

enum direction { UP, DOWN, LEFT, RIGHT }

const CENTERTOSIDE = 1.0;
const SIDETOSIDE = 2 * CENTERTOSIDE;
const PLAYERTOBACKWALL = 0.1;
const CENTERTOPLAYER = 1.0;
const PLAYERFROMCENTER = CENTERTOPLAYER - PLAYERTOBACKWALL;
const HOMETOAWAY = 2 * (CENTERTOPLAYER - PLAYERTOBACKWALL);
const BALLSIZE = 0.04;
const moveLR = 0.2; // move length of moveLeft and moveRight
enum selfOrEnemyDied { selfDied, enemyDied }

class _DevHomePageState extends State<DevHomePage> {
  //LOGIC
  // common params:
  static const selfBrickWidth = 0.4;
  static const enemyBrickWidth = 0.2;
  int awayToHomeTime = 1000; // miliseconds
  final timerRep = 20; // ms
  double get ballMoveD => timerRep / awayToHomeTime;
  final rand = Random(DateTime.now().millisecondsSinceEpoch);

  //ball members for setState
  double ballX = 0;
  double ballY = 0;
  var ballPos = BallPos(0, 0);
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.RIGHT;
  var gameStarted = false;
  final angleGenerator = RandAngleIterator(14); // degree

  //player members for setState
  final playerSize = selfBrickWidth;
  final playerY = PLAYERFROMCENTER - selfBrickWidth / 2;
  double playerX = 0;
  int playerScore = 0;
  final selfPlayer = SelfPlayer(selfBrickWidth);

  // enemy members for setState
  final enemyY = -PLAYERFROMCENTER;
  double enemyX = 0;
  int enemyScore = 0;
  final enemyPlayer = EnemyPlayer(enemyBrickWidth);

  // virtual ball for debug
  double vallX = 0;
  double vallY = 0;


  void startGame() {
    gameStarted = true;
    final int divider = awayToHomeTime ~/ timerRep; // divide to get an integer
    double angle = angleGenerator.current;
    angleGenerator.moveNext();
    logger.info('angle: ${angle / pi * 180}');
    // degreeToRadian(40 + (startFromEnemy ? 180 : 0)); // radian from degree
    ballPos = BallPos.withAngleDivider(angle, divider, yf: PLAYERFROMCENTER); // - selfBrickWidth * 2);
    logger.info(
        'ballPos: x=${ballPos.x}, y=${ballPos.y}, dx=${ballPos.dx}, dy=${ballPos.dy}');
    var startBall = true;
    Tuple2<double, int> ballArrivalPosAndCount =
        ballPos.jumpDown(); // calcLandingPos(ballPos);
    double ballArrivalPos = ballArrivalPosAndCount.item1;
    // final ballArrivalPos = Player.calcBallArrivalPos(ballPos, gameStarted);
    if ((ballArrivalPos - ballPos.x).abs() > 0.1) {
      logger.info("Moving 'cause ballArrivalPos differs more than 0.1 from ball positio1stn: $ballArrivalPos");
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
          logger.info("Upward ball: $ballX, player: $playerX");
          assert(ballX == ballPos.x);
          final meet = ballCatch(ballX, players.SELF);
          if (meet.item1 != catchResult.safe) {
            logger.info('self meet ball: ${meet.item1 == catchResult.under ? 'under' : 'over'}: ${meet.item2 + ballX}');
            enemyPlayer.score++;
            setState(() {
              enemyScore = enemyPlayer.score;
            });
            timer.cancel();
            vCount = 0;
            vInch = 0;
            _showDialog(selfOrEnemyDied.selfDied);
          } else {
            final calculatedBallPos = ballPos.calcBallLandingPos();
            logger.fine("calculatedBallPos: $calculatedBallPos");
            setState(() {
              vallX = calculatedBallPos;
              vallY = -PLAYERFROMCENTER + 0.1;
            });
            vPosAndCount = ballPos.jumpDown();
            vPos = vPosAndCount.item1;
            logger.fine("vPos: $vPos");
            logger.fine(
                "(vPos-calculatedBallPos).abs():${(vPos - calculatedBallPos).abs()}");
            // assert((vPos - calculatedBallPos).abs() < 0.01);
            if (vPos != ballPos.x) {
              logger.info(
                  'calculatedBallPos($calculatedBallPos) :: ($vPos) differs from enemyX($enemyX).');
              vCount = vPosAndCount.item2;
              vInch = (calculatedBallPos - enemyX) / vCount;
            }
          }
          break;
        case stepResult.toPlus:
          logger.info("Downward ball: stepResult.toPlus.");
          final meet = ballCatch(ballX, players.ENEMY);
          switch(meet.item1){
            case catchResult.over:
            case catchResult.under:
            logger.info('enemy catch ball: ${meet.item1 == catchResult.under ? 'under' : 'over'}: ${meet.item2}');
            selfPlayer.score++;
            setState(() {
              playerScore = selfPlayer.score;
            });
            timer.cancel();
            _showDialog(selfOrEnemyDied.enemyDied);
            break;
            default:
            vCount = 0;
            vInch = 0;
          }
          break;
        default:
          break;
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
    if (selfPlayer.x == selfPlayer.leftEdge)
      return;
    var newX = ((selfPlayer.x - moveLR) < selfPlayer.leftEdge) ?
      selfPlayer.leftEdge : selfPlayer.x - moveLR;
    if (newX != selfPlayer.x)
    setState(() {
      playerX = selfPlayer.x = newX;
    });
  }

  void moveRight() {
    if (selfPlayer.x == selfPlayer.rightEdge)
      return;
    var newX = ((selfPlayer.x + moveLR) > selfPlayer.rightEdge) ?
        selfPlayer.rightEdge : selfPlayer.x + moveLR;
    if(newX != selfPlayer.x)
    setState(() {
      playerX = selfPlayer.x = newX;
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
                Score(gameStarted, enemyScore, playerScore),
                // self brick on bottom
                Brick(enemyPlayer, enemyX, -0.9),
                // Paddle(enemyPlayer, enemyX + enemyPlayer.width/2, 0.2, 0.2),
                //scoreboard
                Brick(selfPlayer, playerX, 0.9),
                // ball
                Ball(ballX, ballY, BALLSIZE),
                //Paddle(selfPlayer, playerX),
                //Paddle(selfPlayer, playerX, 1.0, 0.4),
                // Paddle(selfPlayer, playerX + selfPlayer.width/2, 0.2, 0.2),
                // Ball(playerX, playerY/2, selfBrickWidth, Colors.pink, BoxShape.circle),
                // Ball(playerX, playerY/2, selfBrickWidth - 0.05, Colors.black, BoxShape.circle),
                // virtual ball
                //Ball(vallX, vallY, 0.02, Colors.yellow),

              ],
            ))),
      ),
    );
  }
  Tuple2<catchResult, double> ballCatch(double bp, players player) {
    final x = (player == players.SELF) ? playerX : enemyX;
    final w = (player == players.SELF) ? selfPlayer.width : enemyPlayer.width;
    final e = SIDETOSIDE * w / 2;
    if (bp > (x + e)) {
      logger.fine("bp: $bp, x: $x, e: $e, x + e: ${x + e}, bp-(x+e):${bp-(x+e)}");
      return Tuple2(catchResult.over, bp - (x + e));
    }
    if (bp < (x - e)) {
      logger.fine("bp: $bp, x: $x, e: $e, x - e: ${x - e}, bp-(x-e):${bp-(x-e)}");
      return Tuple2(catchResult.under, bp - (x - e));
    }
    return Tuple2(catchResult.safe, 0);
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
