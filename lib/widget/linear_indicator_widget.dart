import 'package:flutter/material.dart';

import '../screen/animation_screen.dart';

class LinearIndicator extends StatefulWidget {
  const LinearIndicator({Key? key}) : super(key: key);

  @override
  State<LinearIndicator> createState() => LinearIndicatorState();
}

class LinearIndicatorState extends State<LinearIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController linearController;
  double current = 0.2;

  @override
  void initState() {
    linearController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 150),
        lowerBound: current)
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  @override
  void dispose() {
    linearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Colors.white,
      color: pinkColor,
      borderRadius: BorderRadius.circular(4),
      value: linearController.value,
    );
  }

  void transition() {
    current += 0.1;
    linearController.animateTo(current, curve: Curves.bounceOut);
  }
}
