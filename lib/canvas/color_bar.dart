import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ColorBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;

  const ColorBar({
    Key? key,
    required this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.black,
      Colors.grey,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.pink,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: [
            for (Color color in colors)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => selectedColor.value = color,
                  child: Container(
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: selectedColor.value == color
                            ? Colors.blue
                            : Colors.grey,
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
