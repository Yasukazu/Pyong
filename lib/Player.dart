import 'package:flutter/material.dart';

enum players { SELF, ENEMY }

class PlayerColor {
  static Color get self => Colors.pink;
  static Color get enemy => Colors.purple;
}

// Player class
class Player {
  var x = -0.2; // starting horizontal position
  final double y;
  var score = 0;
  final Color color;
  var diff = 0.0; // keep lost ball reach
  static const fromCenter = 0.9;
  Player(this.y, this.color);
}
