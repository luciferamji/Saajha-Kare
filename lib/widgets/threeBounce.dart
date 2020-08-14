import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math show sin, pi;

import 'package:flutter/animation.dart';

class DelayTween extends Tween<double> {
  DelayTween({double begin, double end, this.delay})
      : super(begin: begin, end: end);

  final double delay;

  @override
  double lerp(double t) =>
      super.lerp((math.sin((t - delay) * 2 * math.pi) + 1) / 2);

  @override
  double evaluate(Animation<double> animation) => lerp(animation.value);
}

class SpinKitThreeBounce extends StatefulWidget {
  const SpinKitThreeBounce({
    Key key,
    this.color,
    this.size = 50.0,
    this.itemBuilder,
    this.duration = const Duration(milliseconds: 1400),
    this.controller,
  })  : assert(
            !(itemBuilder is IndexedWidgetBuilder && color is Color) &&
                !(itemBuilder == null && color == null),
            'You should specify either a itemBuilder or a color'),
        assert(size != null),
        super(key: key);

  final Color color;
  final double size;
  final IndexedWidgetBuilder itemBuilder;
  final Duration duration;
  final AnimationController controller;

  @override
  _SpinKitThreeBounceState createState() => _SpinKitThreeBounceState();
}

class _SpinKitThreeBounceState extends State<SpinKitThreeBounce>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = (widget.controller ??
        AnimationController(vsync: this, duration: widget.duration))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (i) {
          return ScaleTransition(
            scale: DelayTween(begin: 0.0, end: 1.0, delay: i * 1.3)
                .animate(_controller),
            child: SizedBox.fromSize(
                size: Size.square(widget.size * 0.5), child: _itemBuilder(i)),
          );
        }),
      ),
    );
  }

  Widget _itemBuilder(int index) {
    if (widget.itemBuilder != null)
      return widget.itemBuilder(context, index);
    else {
      if (index % 3 == 0)
        return DecoratedBox(
            decoration:
                BoxDecoration(color: Colors.orange, shape: BoxShape.circle));
      else if (index % 3 == 1)
        return DecoratedBox(
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 3)));
      else
        return DecoratedBox(
            decoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ));
    }
  }
}
