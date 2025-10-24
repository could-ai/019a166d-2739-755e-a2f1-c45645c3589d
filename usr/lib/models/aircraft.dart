import 'package:flutter/painting.dart';

class Aircraft {
  String id;
  String callsign;
  String type;
  int flightLevel;
  String squawk;
  int speed;
  Offset position;
  Offset tagPosition;

  Aircraft({
    required this.id,
    required this.callsign,
    required this.type,
    required this.flightLevel,
    required this.squawk,
    required this.speed,
    required this.position,
    required this.tagPosition,
  });

  String get displayInfo => '$callsign\n$type\nFL$flightLevel\n$speed kt\n$squawk';
}
