import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StickerBar extends HookWidget {
  const StickerBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      Icons.heart_broken_sharp,
      Icons.safety_check,
      Icons.search,
      Icons.sailing,
      Icons.heart_broken_sharp,
      Icons.heart_broken_sharp,
      Icons.heart_broken_sharp,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          runSpacing: 5,
          children: [
            for (IconData icon in icons)
              Draggable<IconData>(
                data: icon,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Icon(
                  icon,
                  size: 30,
                ),
                child: Icon(
                  icon,
                  size: 30,
                ),
              )
          ],
        ),
      ],
    );
  }
}
