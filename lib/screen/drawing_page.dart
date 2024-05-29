import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_hooks/flutter_hooks.dart';

import '../canvas/drawing_canvas.dart';
import '../canvas/sketch.dart';
import '../canvas/tool_bar.dart';

class DrawingPage extends HookWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              width: double.maxFinite,
              margin: const EdgeInsets.only(top: 348),
              height: MediaQuery.of(context).size.height - 348,
              child: DrawingCanvas(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 348,
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                sideBarController: animationController,
                currentSketch: currentSketch,
                allSketches: allSketches,
                canvasGlobalKey: canvasGlobalKey,
                filled: filled,
              ),
            ),
            Positioned(
              top: 48,
              // left: -5,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animationController),
                child: ToolBar(
                  drawingMode: drawingMode,
                  selectedColor: selectedColor,
                  currentSketch: currentSketch,
                  allSketches: allSketches,
                  canvasGlobalKey: canvasGlobalKey,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox(width: 48, height: 48, child: Center(
                child: Icon(Icons.arrow_back),
              ),),
            )
          ],
        ),
      ),
    );
  }
}