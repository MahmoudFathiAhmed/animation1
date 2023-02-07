import 'dart:math' show pi;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Title',
      theme: ThemeData(brightness: Brightness.dark),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      debugShowMaterialGrid: false,
      home: const HomePage(),
    );
  }
}

enum CircleSide { left, right }

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();
    late Offset offset;
    late bool clockWise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockWise = false;
        break;
      case CircleSide.right:
        offset = Offset(0, size.height);
        clockWise = true;
        break;
    }
    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.width / 2, size.height / 2),
      clockwise: clockWise,
    );

    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  final CircleSide side;

  const HalfCircleClipper({required this.side});
  @override
  Path getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

extension on VoidCallback {
  Future<void> delayed(Duration duration) => Future.delayed(duration, this);
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _counterClockwiseRotationController;
  late Animation<double> _counterClockwiseRotationAnimation;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _counterClockwiseRotationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _counterClockwiseRotationAnimation = Tween<double>(
      begin: 0,
      end: -(pi / 2.0),
    ).animate(CurvedAnimation(
      parent: _counterClockwiseRotationController,
      curve: Curves.bounceOut,
    ));

    //flip animatiosn
    _flipController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _flipAnimation = Tween<double>(
      begin: 0,
      end: -pi,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.bounceOut,
    ));
    //status listner

    _counterClockwiseRotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipController.forward();
        _flipAnimation = Tween<double>(
          begin: _flipAnimation.value,
          end: _flipAnimation.value + pi,
        ).animate(
          CurvedAnimation(
            parent: _flipController,
            curve: Curves.bounceOut,
          ),
        );
        //reset the flip controller and start animation
        _flipController
          ..reset()
          ..forward();
      }
    });

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _counterClockwiseRotationAnimation = Tween<double>(
          begin: _counterClockwiseRotationAnimation.value,
          end: _counterClockwiseRotationAnimation.value + -(pi / 2),
        ).animate(CurvedAnimation(
          parent: _counterClockwiseRotationController,
          curve: Curves.bounceOut,
        ));
        _counterClockwiseRotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    _counterClockwiseRotationController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _counterClockwiseRotationController
      ..reset()
      ..forward.delayed(const Duration(seconds: 1));
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          builder: (context, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(_counterClockwiseRotationAnimation.value),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedBuilder(
                animation: _flipController,
                builder: (context, child) => Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()..rotateY(_flipAnimation.value),
                  child: ClipPath(
                    clipper: const HalfCircleClipper(side: CircleSide.left),
                    child: Container(
                      color: const Color(0xff0057b7),
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) => Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()..rotateY(_flipAnimation.value),
                  child: ClipPath(
                    clipper: const HalfCircleClipper(side: CircleSide.right),
                    child: Container(
                      color: const Color(0xffffd700),
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              )
            ]),
          ),
          animation: _counterClockwiseRotationAnimation,
        ),
      ),
    );
  }
}
