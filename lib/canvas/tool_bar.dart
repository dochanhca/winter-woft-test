import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gal/gal.dart';
import 'package:winter_woft_test/canvas/sticker_bar.dart';

import 'color_bar.dart';
import 'sketch.dart';

class ToolBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;

  const ToolBar({
    Key? key,
    required this.selectedColor,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final undoRedoStack = useState(
      _UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );
    final scrollController = useScrollController();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 3,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          controller: scrollController,
          children: [
            const Text(
              'Mode',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 5,
              children: [
                GestureDetector(
                  onTap: () => drawingMode.value = DrawingMode.pencil,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        color: drawingMode.value == DrawingMode.pencil
                            ? Colors.blue
                            : Colors.white),
                    child: Text(
                      'Draw',
                      style: TextStyle(
                          color: drawingMode.value == DrawingMode.pencil
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => drawingMode.value = DrawingMode.eraser,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        color: drawingMode.value == DrawingMode.eraser
                            ? Colors.blue
                            : Colors.white),
                    child: Text(
                      'Erase',
                      style: TextStyle(
                          color: drawingMode.value == DrawingMode.eraser
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                const Text(
                  'selected color',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: selectedColor.value,
                    border: Border.all(color: Colors.blue, width: 1.5),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Colors',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ColorBar(
              selectedColor: selectedColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Stickers',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            const StickerBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Wrap(
                  children: [
                    TextButton(
                      onPressed: allSketches.value.isNotEmpty
                          ? () => undoRedoStack.value.undo()
                          : null,
                      child: const Text('Undo'),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: undoRedoStack.value._canRedo,
                      builder: (_, canRedo, __) {
                        return TextButton(
                          onPressed:
                              canRedo ? () => undoRedoStack.value.redo() : null,
                          child: const Text('Redo'),
                        );
                      },
                    ),
                    TextButton(
                      child: const Text('Clear'),
                      onPressed: () => undoRedoStack.value.clear(),
                    ),
                    TextButton(
                      child: const Text('Export image'),
                      onPressed: () => saveFile(context),
                    ),
                  ],
                ),
              ],
            ) // add about me button or follow buttons
          ],
        ),
      ),
    );
  }

  void saveFile(BuildContext context) async {
    try {
      Uint8List? pngBytes = await getBytes();
      await Gal.putImageBytes(pngBytes!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Save image success"),
      ));
    } on GalException catch (e) {
      log(e.type.message);
    }
  }

  Future<Uint8List?> getBytes() async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }
}

class _UndoRedoStack {
  _UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;

  late final List<Sketch> _redoStack = [];

  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
