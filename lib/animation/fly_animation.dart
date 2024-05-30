import 'dart:math';

import 'package:flutter/material.dart';

import '../screen/animation_screen.dart';
import '../widget/heart_count_widget.dart';

extension GlobalKeyExt on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

class _PositionedAnimationModel {
  bool showAnimation = false;
  bool animationActive = false;
  Offset imageSourcePoint = Offset.zero;
  Offset imageDestPoint = Offset.zero;
  Size imageSourceSize = Size.zero;
  Size imageDestSize = Size.zero;
  bool rotation = false;
  double opacity = 0.85;
  late Container container;
  Duration duration = Duration.zero;
  Curve curve = Curves.easeIn;
}

class FlyAnimation extends StatefulWidget {
  final Widget child;

  final GlobalKey<HeartCountState> heartCountKey;

  final Function(Future<void> Function(GlobalKey)) createAddToCartAnimation;

  final double opacity;

  const FlyAnimation({
    Key? key,
    required this.child,
    required this.heartCountKey,
    required this.createAddToCartAnimation,
    this.opacity = 0.85,
  }) : super(key: key);

  @override
  _FlyAnimationState createState() => _FlyAnimationState();
}

class _FlyAnimationState extends State<FlyAnimation> {
  List<_PositionedAnimationModel> animationModels = [];

  @override
  void initState() {
    widget.createAddToCartAnimation(runAddToCartAnimation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Stack(
            children: animationModels
                .map<Widget>((model) => model.showAnimation
                    ? AnimatedPositioned(
                        top: model.animationActive
                            ? model.imageDestPoint.dx
                            : model.imageSourcePoint.dx,
                        left: model.animationActive
                            ? model.imageDestPoint.dy
                            : model.imageSourcePoint.dy,
                        height: model.animationActive
                            ? model.imageDestSize.height
                            : model.imageSourceSize.height,
                        width: model.animationActive
                            ? model.imageDestSize.width
                            : model.imageSourceSize.width,
                        duration: model.duration,
                        curve: model.curve,
                        child: model.rotation
                            ? TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0, end: -pi / 6),
                                duration: model.duration,
                                child: model.container,
                                builder: (context, double value, widget) {
                                  return Transform.rotate(
                                    angle: value,
                                    child: Opacity(
                                      opacity: model.opacity,
                                      child: widget,
                                    ),
                                  );
                                },
                              )
                            : Opacity(
                                opacity: model.opacity,
                                child: model.container,
                              ),
                      )
                    : Container())
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> runAddToCartAnimation(GlobalKey widgetKey) async {
    _PositionedAnimationModel animationModel = _PositionedAnimationModel()
      ..rotation = false
      ..opacity = widget.opacity;

    animationModel.imageSourcePoint = Offset(
        widgetKey.globalPaintBounds!.top, widgetKey.globalPaintBounds!.left);

    animationModel.imageSourceSize = Size(widgetKey.currentContext!.size!.width,
        widgetKey.currentContext!.size!.height);

    animationModels.add(animationModel);
    animationModel.container = Container(
      child: (widgetKey.currentWidget! as RotationTransition).child,
    );

    animationModel.showAnimation = true;

    setState(() {});

    await Future.delayed(const Duration(milliseconds: 25));
    animationModel.animationActive = true;
    setState(() {});

    await Future.delayed(animationModel.duration);

    animationModel.curve = Curves.linear;
    animationModel.duration = const Duration(milliseconds: heartFlyDuration);

    animationModel.imageDestPoint = Offset(
        widget.heartCountKey.globalPaintBounds!.top,
        widget.heartCountKey.globalPaintBounds!.left);

    animationModel.imageDestSize = Size(
        widget.heartCountKey.currentContext!.size!.width,
        widget.heartCountKey.currentContext!.size!.height);

    setState(() {});

    await Future.delayed(animationModel.duration);
    animationModel.showAnimation = false;
    animationModel.animationActive = false;

    setState(() {});

    return;
  }
}
