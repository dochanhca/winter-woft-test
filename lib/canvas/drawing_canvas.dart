import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';

import 'sketch.dart';

class DrawingCanvas extends HookWidget {
  final double height;
  final double width;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<DrawingMode> drawingMode;
  final AnimationController sideBarController;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;

  const DrawingCanvas({
    Key? key,
    required this.height,
    required this.width,
    required this.selectedColor,
    required this.drawingMode,
    required this.sideBarController,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.precise,
      child: Stack(
        children: [
          buildAllSketches(context),
          buildCurrentPath(context),
        ],
      ),
    );
  }

  void onPointerDown(PointerDownEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        size: drawingMode.value == DrawingMode.eraser ? 30 : 10,
        color: drawingMode.value == DrawingMode.eraser
            ? Colors.white
            : selectedColor.value,
      ),
      drawingMode.value,
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    final points = List<Offset>.from(currentSketch.value?.points ?? [])
      ..add(offset);

    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        size: drawingMode.value == DrawingMode.eraser ? 30 : 10,
        color: drawingMode.value == DrawingMode.eraser
            ? Colors.white
            : selectedColor.value,
      ),
      drawingMode.value,
    );
  }

  void onPointerUp(PointerUpEvent details) {
    allSketches.value = List<Sketch>.from(allSketches.value)
      ..add(currentSketch.value!);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [],
        size: drawingMode.value == DrawingMode.eraser ? 30 : 10,
        color: drawingMode.value == DrawingMode.eraser
            ? Colors.white
            : selectedColor.value,
      ),
      drawingMode.value,
    );
  }

  Widget buildAllSketches(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ValueListenableBuilder<List<Sketch>>(
        valueListenable: allSketches,
        builder: (context, sketches, _) {
          return RepaintBoundary(
            key: canvasGlobalKey,
            child: Container(
              height: height,
              width: width,
              color: Colors.white,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return DragTarget<IconData>(
      builder: (context, candidateItems, rejectedItems) => Listener(
        onPointerDown: (details) => onPointerDown(details, context),
        onPointerMove: (details) => onPointerMove(details, context),
        onPointerUp: onPointerUp,
        child: ValueListenableBuilder(
          valueListenable: currentSketch,
          builder: (context, sketch, child) {
            return RepaintBoundary(
              child: SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  painter: SketchPainter(
                    sketches: sketch == null ? [] : [sketch],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      onAcceptWithDetails: (details) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(details.offset);
        allSketches.value = List<Sketch>.from(allSketches.value)
          ..add(Sketch(points: [offset], size: 0, icon: details.data));
      },
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;
  final Image? backgroundImage;

  const SketchPainter({
    Key? key,
    this.backgroundImage,
    required this.sketches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (Sketch sketch in sketches) {
      if (sketch.icon != null) {
        IconData icon = sketch.icon!;
        TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
        textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontFamily: icon.fontFamily,
            package: icon
                .fontPackage, // This line is mandatory for external icon packs
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, sketch.points.first);
        continue;
      }
      final points = sketch.points;
      if (points.isEmpty) return;

      final path = Path();

      path.moveTo(points[0].dx, points[0].dy);
      if (points.length < 2) {
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: 1,
          ),
        );
      }

      for (int i = 1; i < points.length - 1; ++i) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round;

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = sketch.size;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return oldDelegate.sketches != sketches;
  }
}
