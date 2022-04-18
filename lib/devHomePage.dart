import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pong/ball.dart';
import 'package:pong/brick.dart';
import 'package:pong/welcomeScreen.dart';
import 'package:pong/Player.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

enum direction { UP, DOWN, LEFT, RIGHT }

const CENTERTOSIDE = 1.0;
const PLAYERTOBACKWALL = 0.1;
const CENTERTOPLAYER = 1.0;
const PLAYERFROMCENTER = CENTERTOPLAYER - PLAYERTOBACKWALL;
const HOMETOAWAY = 2 * (CENTERTOPLAYER - PLAYERTOBACKWALL);

class _HomePageState extends State<HomePage> {
  //LOGIC
  // common params:
  static const selfBrickWidth = 0.5;
  static const enemyBrickWidth = 0.2;
  final moveLR = 0.2; // move length of moveLeft and moveRight
  int awayToHomeTime = 1000; // miliseconds
  final timerRep = 20; // ms
  double get ballMoveD => timerRep / awayToHomeTime;
  //player variations
  // double playerX = -0.2;
  int playerScore = 0;
  final selfPlayer = SelfPlayer(selfBrickWidth);

  // enemy variable
  // double enemyX = -0.2;
  int enemyScore = 0;
  final enemyPlayer = EnemyPlayer(enemyBrickWidth);

  //ball
  double ballx = 0;
  double bally = 0;
  var ballPos = BallPos(0, 0);
  var ballYDirection = direction.DOWN;
  var ballXDirection = direction.RIGHT;
  var gameStarted = false;

  void startGame() {
    gameStarted = true;
    final int divider = awayToHomeTime ~/ timerRep; // divide to get an integer
    bool startFromEnemy = true;
    double angle = atan2(1, -2);
    print('angle: ${angle / pi * 180}');
    // degreeToRadian(40 + (startFromEnemy ? 180 : 0)); // radian from degree
    ballPos = BallPos.withAngleDivider(angle, divider, yf: PLAYERFROMCENTER);
    print(
        'ballPos: x=${ballPos.x}, y=${ballPos.y}, dx=${ballPos.dx}, dy=${ballPos.dy}');
    var startBall = true;
    Timer.periodic(Duration(milliseconds: timerRep), (timer) {
      final stepResults = ballPos.step();
      // xy.forEach((e) { // debug print print('$e, '); });
      setState(() {
        ballx = ballPos.x;
        bally = ballPos.y;
      });

      if (startBall && ballPos.dy < 0 || stepResults.y == stepResult.toMinus) {
        double x = 0;
        if (startBall) {
          x = enemyPlayer.calcBallArrivalFromCenter(ballPos);
          startBall = false;
        } else {
          x = enemyPlayer.simulateBallArrival(ballPos);
        }
        print('enemyPos: $x');
        assert(x.abs() <= CENTERTOSIDE);
        setState(() {
          // moveEnemyTo(x);
          enemyPlayer.x = x;
        });
      } else if (stepResults.y == stepResult.toMinus) {}

      if (isPlayerDead()) {
        enemyScore++;
        timer.cancel();
        _showDialog(false);
        // resetGame();
      }
      if (isEnemyDead()) {
        playerScore++;
        enemyPlayer.diff = (ballx - enemyPlayer.x).abs();
        print(enemyPlayer.diff);
        timer.cancel();
        _showDialog(true);
        // resetGame();
      }
    });
  }

  bool isEnemyDead() {
    if (bally <= -1) {
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
    final lastPos = ballx;
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

  void _showDialog(bool enemyDied) {
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
                enemyDied ? "You win." : "Opponent win.",
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
                            color: enemyDied
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
      gameStarted = false;
      ballx = 0;
      bally = 0;
      selfPlayer.x = -0.2;
      enemyPlayer.x = -0.2;
    });
  }

  bool isPlayerDead() {
    if (bally >= 0.9) {
      return true;
    }
    return false;
  }


  void moveBall() {
    //vertical movement
    setState(() {
      if (ballYDirection == direction.DOWN) {
        bally += ballMoveD;
      } else if (ballYDirection == direction.UP) {
        bally -= ballMoveD;
      }
    });
    //horizontal movement
    setState(() {
      if (ballXDirection == direction.LEFT) {
        ballx -= ballMoveD;
      } else if (ballXDirection == direction.RIGHT) {
        ballx += ballMoveD;
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (!(selfPlayer.x - moveLR < -1)) {
        selfPlayer.x -= moveLR;
      } else {
        selfPlayer.x = -1;
      }
    });
  }

  void moveRight() {
    if (!(selfPlayer.x + moveLR > 1)) {
      selfPlayer.x += moveLR;
    } else {
      selfPlayer.x = 1 - moveLR;
    }
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
                Brick(enemyPlayer),
                //scoreboard
                Score(gameStarted, enemyScore, playerScore),
                // ball
                Ball(ballx, bally),
                // self brick on bottom
                Brick(selfPlayer)
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
