import "package:flutter/material.dart";
import 'package:pimp_my_button/pimp_my_button.dart';
import "dart:math" show pi;

class MyParticle extends Particle {
  final Color color;

  MyParticle(this.color);
  @override
  void paint(Canvas canvas, Size size, progress, seed) {
    int randomMirrorOffset = 6;
    CompositeParticle(children: [
      // Firework(),
      CircleMirror(
          numberOfParticles: 16,
          child: AnimatedPositionedParticle(
            begin: Offset(0.0, 50.0),
            end: Offset(0.0, 90.0),
            child: FadingCircle(radius: 3.0, color: color),
          ),
          initialRotation: -pi / randomMirrorOffset),
      CircleMirror.builder(
          numberOfParticles: 16,
          particleBuilder: (index) {
            return IntervalParticle(
                child: AnimatedPositionedParticle(
                  begin: Offset(0.0, 50.0),
                  end: Offset(0.0, 70.0),
                  child: FadingCircle(radius: 3.0, color: color),
                ),
                interval: Interval(
                  0.5,
                  1,
                ));
          },
          initialRotation: -pi / randomMirrorOffset),
    ]).paint(canvas, size, progress, seed);
  }
}
