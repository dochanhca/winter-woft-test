import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:winter_woft_test/animation/fly_animation.dart';
import 'package:winter_woft_test/widget/heart_count_widget.dart';
import 'package:winter_woft_test/widget/linear_indicator_widget.dart';

const heartFlyDuration = 300;
const animationDuration = 150;
const shortAnimationDuration = 75;
const pinkColor = Color(0xffaf6eff);
const heartSize = 50.0;

class AnimationPage extends HookWidget {
  final GlobalKey<HeartCountState> heartCountKey = GlobalKey<HeartCountState>();
  final GlobalKey<LinearIndicatorState> indicatorKey =
      GlobalKey<LinearIndicatorState>();
  Function(GlobalKey)? runAddToCartAnimation;

  AnimationController? heartFadeController1;
  AnimationController? heartFadeController2;

  AnimationController? fadeImageTransitionController;
  AnimationController? fadeContentTransitionController;
  AnimationController? slideContentTransitionController;

  AnimationController? heartRotationController1;
  AnimationController? heartSmallScaleController1;
  AnimationController? heartScaleController1;

  AnimationController? heartRotationController2;
  AnimationController? heartSmallScaleController2;
  AnimationController? heartScaleController2;

  AnimationController? containerScaleController;
  AnimationController? colorAnimationController;

  final GlobalKey heart1Key = GlobalKey();
  final GlobalKey heart2Key = GlobalKey();

  AnimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    fadeImageTransitionController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    fadeContentTransitionController = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    slideContentTransitionController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    heartFadeController1 = useAnimationController(
      duration: const Duration(milliseconds: animationDuration),
    );

    heartFadeController2 = useAnimationController(
      duration: const Duration(milliseconds: animationDuration),
    );

    heartRotationController1 = useAnimationController(
      duration: const Duration(milliseconds: animationDuration),
    );
    heartSmallScaleController1 = useAnimationController(
      duration: const Duration(milliseconds: shortAnimationDuration),
    );
    heartScaleController1 = useAnimationController(
      duration: const Duration(milliseconds: animationDuration),
    );

    heartRotationController2 = useAnimationController(
      duration: const Duration(milliseconds: animationDuration),
    );
    heartSmallScaleController2 = useAnimationController(
      duration: const Duration(milliseconds: shortAnimationDuration),
    );
    heartScaleController2 = useAnimationController(
      duration: const Duration(milliseconds: animationDuration),
    );

    containerScaleController = useAnimationController(
      duration: const Duration(milliseconds: shortAnimationDuration),
    );

    colorAnimationController =
        useAnimationController(duration: const Duration(milliseconds: 15));

    Animation<double> fadeImageTransition = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
        parent: fadeImageTransitionController!, curve: Curves.easeInOut));

    Animation<double> fadeContentTransition = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
        parent: fadeContentTransitionController!, curve: Curves.easeInOut));

    Animation<Offset> slideContentTransition = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(slideContentTransitionController!);

    Future.delayed(const Duration(milliseconds: 200), () {
      fadeImageTransitionController?.forward().then((value) async {
        fadeContentTransitionController?.forward();
        await Future.delayed(const Duration(milliseconds: 100));
        slideContentTransitionController?.forward();
      });
    });

    Animation<double> smallScaleAnimation1 = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(heartSmallScaleController1!);

    Animation<double> scaleAnimation1 = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(heartScaleController1!);

    Animation<double> smallScaleAnimation2 = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(heartSmallScaleController2!);

    Animation<double> scaleAnimation2 = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(heartScaleController2!);

    Animation<double> containerScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(containerScaleController!);

    Animation colorTween = ColorTween(
            begin: Colors.grey.withOpacity(0.3),
            end: pinkColor.withOpacity(0.25))
        .animate(colorAnimationController!);

    return FlyAnimation(
      heartCountKey: heartCountKey,
      opacity: 0.85,
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Animation screen'),
          centerTitle: false,
          actions: [
            OutlinedButton(
                onPressed: () => _startAnimation(),
                child: Text('Start Animation',
                    style: Theme.of(context).textTheme.titleMedium))
          ],
        ),
        body: Column(
          children: [
            FadeTransition(
              opacity: fadeImageTransition,
              child: Image.asset(
                'asset/images/dress.jpg',
                width: MediaQuery.of(context).size.width,
              ),
            ),
            const SizedBox(height: 20),
            SlideTransition(
              position: slideContentTransition,
              child: FadeTransition(
                opacity: fadeContentTransition,
                child: Column(
                  children: [
                    _buildHeartRow(scaleAnimation1, smallScaleAnimation1,
                        scaleAnimation2, smallScaleAnimation2),
                    const SizedBox(height: 60),
                    AnimatedBuilder(
                      builder: (_, Widget? child) => Transform.scale(
                        scale: containerScaleAnimation.value,
                        child: child,
                      ),
                      animation: containerScaleController!,
                      child: AnimatedBuilder(
                        builder: (_, child) => Container(
                          decoration: BoxDecoration(
                              color: colorTween.value,
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('NEXT MILESTONE'),
                                  HeartCountWidget(
                                    key: heartCountKey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearIndicator(
                                key: indicatorKey,
                              ),
                            ],
                          ),
                        ),
                        animation: colorAnimationController!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRow(
      Animation<double> scaleAnimation1,
      Animation<double> smallScaleAnimation1,
      Animation<double> scaleAnimation2,
      Animation<double> smallScaleAnimation2) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      FadeTransition(
        opacity: Tween(begin: 0.5, end: 1.0).animate(heartFadeController1!),
        child: RotationTransition(
          key: heart1Key,
          turns:
              Tween(begin: 0.0, end: -0.05).animate(heartRotationController1!),
          child: AnimatedBuilder(
            builder: (_, Widget? child) => Transform.scale(
              scale: scaleAnimation1.value,
              child: child,
            ),
            animation: heartScaleController1!,
            child: AnimatedBuilder(
              builder: (_, Widget? child) => Transform.scale(
                scale: smallScaleAnimation1.value,
                child: child,
              ),
              animation: heartSmallScaleController1!,
              child: _buildHeart(),
            ),
          ),
        ),
      ),
      FadeTransition(
        opacity: Tween(begin: 0.5, end: 1.0).animate(heartFadeController2!),
        child: RotationTransition(
          key: heart2Key,
          turns:
              Tween(begin: 0.0, end: -0.05).animate(heartRotationController2!),
          child: AnimatedBuilder(
            builder: (_, Widget? child) => Transform.scale(
              scale: scaleAnimation2.value,
              child: child,
            ),
            animation: heartScaleController2!,
            child: AnimatedBuilder(
              builder: (_, Widget? child) => Transform.scale(
                scale: smallScaleAnimation2.value,
                child: child,
              ),
              animation: heartSmallScaleController2!,
              child: _buildHeart(),
            ),
          ),
        ),
      ),
      Opacity(opacity: 0.5, child: _buildHeart()),
    ]);
  }

  Container _buildHeart() {
    return Container(
      margin: const EdgeInsets.only(left: 10, top: 10),
      width: heartSize,
      height: heartSize,
      child: const Icon(
        Icons.heart_broken_outlined,
        size: heartSize,
        color: pinkColor,
      ),
    );
  }

  void _startAnimation() async {
    await heartSmallScaleController1?.forward();
    await heartSmallScaleController1?.reverse();
    //
    await heartSmallScaleController2?.forward();
    await heartSmallScaleController2?.reverse();

    await Future.value(
        [heartScaleController1?.forward(), heartFadeController1?.forward()]);
    await Future.value(
        [heartScaleController1?.forward(), heartFadeController2?.forward()]);
    // await heartScaleController1.forward();
    // await heartScaleController2.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    await heartRotationController1?.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await heartRotationController2?.forward();
    // await Future.delayed(const Duration(milliseconds: 200));
    heartScaleController1?.reset();
    heartRotationController1?.reset();

    await _heart1FlyAnimation();
    heartScaleController2?.reset();
    heartRotationController2?.reset();
    _heart2FlyAnimation();
  }

  Future<void> _heart1FlyAnimation() async {
    await runAddToCartAnimation!(heart1Key);
    containerScaleController
        ?.forward()
        .then((value) => containerScaleController?.reverse());
    colorAnimationController
        ?.forward()
        .then((value) => colorAnimationController?.reverse());
    indicatorKey.currentState!.transition();
    heartCountKey.currentState!.addHeart();
  }

  Future<void> _heart2FlyAnimation() async {
    await runAddToCartAnimation!(heart2Key);
    containerScaleController
        ?.forward()
        .then((value) => containerScaleController?.reverse());
    colorAnimationController
        ?.forward()
        .then((value) => colorAnimationController?.reverse());
    indicatorKey.currentState!.transition();
    heartCountKey.currentState!.addHeart();
  }
}
