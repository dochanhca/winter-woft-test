import 'package:flutter/material.dart';

enum DrawingMode { pencil, eraser }

class Sketch {
  final List<Offset> points;
  final Color color;
  final double size;
  final IconData? icon;

  Sketch({
    required this.points,
    this.color = Colors.black,
    this.icon,
    required this.size,
  });

  factory Sketch.fromDrawingMode(
    Sketch sketch,
    DrawingMode drawingMode,
  ) {
    return Sketch(
      points: sketch.points,
      color: sketch.color,
      size: sketch.size,
    );
  }
}

extension ColorExtension on String {
  Color toColor() {
    var hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    } else {
      return Colors.black;
    }
  }
}

extension ColorExtensionX on Color {
  String toHex() => '#${value.toRadixString(16).substring(2, 8)}';
}
