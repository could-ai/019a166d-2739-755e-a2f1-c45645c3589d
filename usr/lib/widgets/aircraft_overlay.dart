import 'package:flutter/material.dart';
import '../../models/aircraft.dart';

class AircraftOverlay extends StatelessWidget {
  final List<Aircraft> aircrafts;
  final Function(Aircraft, Offset) onTagMoved;

  const AircraftOverlay({
    super.key,
    required this.aircrafts,
    required this.onTagMoved,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: aircrafts.map((aircraft) => AircraftTarget(
        aircraft: aircraft,
        onTagMoved: onTagMoved,
      )).toList(),
    );
  }
}

class AircraftTarget extends StatelessWidget {
  final Aircraft aircraft;
  final Function(Aircraft, Offset) onTagMoved;

  const AircraftTarget({
    super.key,
    required this.aircraft,
    required this.onTagMoved,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Aircraft square
        Positioned(
          left: aircraft.position.dx - 5,
          top: aircraft.position.dy - 5,
          child: Container(
            width: 10,
            height: 10,
            color: Colors.red,
          ),
        ),
        // Connecting line
        CustomPaint(
          painter: LinePainter(
            start: aircraft.position,
            end: aircraft.tagPosition,
          ),
          child: Container(),
        ),
        // Movable data tag
        Positioned(
          left: aircraft.tagPosition.dx,
          top: aircraft.tagPosition.dy,
          child: Draggable(
            feedback: _buildDataTag(isDragging: true),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              onTagMoved(aircraft, details.offset);
            },
            child: _buildDataTag(),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTag({bool isDragging = false}) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDragging ? Colors.blue.withOpacity(0.7) : Colors.white.withOpacity(0.8),
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        aircraft.displayInfo,
        style: const TextStyle(fontSize: 10, color: Colors.black),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  LinePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
