import 'package:flutter/material.dart';

import '../screen/animation_screen.dart';

class HeartCountWidget extends StatefulWidget {
  @override
  final GlobalKey<HeartCountState> key;

  const HeartCountWidget({
    required this.key,
  }) : super(key: key);

  @override
  HeartCountState createState() => HeartCountState();
}

class HeartCountState extends State<HeartCountWidget>
    with SingleTickerProviderStateMixin {
  int heartCount = 2;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: shortAnimationDuration),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(0, 0.0),
    end: const Offset(.1, 0.0),
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SlideTransition(
          position: _offsetAnimation,
          child: const Icon(
            Icons.heart_broken_outlined,
            color: pinkColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 2),
        Text('$heartCount/10')
      ],
    );
  }

  Future<void> addHeart() async {
    await _controller.forward();
    await _controller.reverse();
    setState(() {
      heartCount++;
    });
  }
}
