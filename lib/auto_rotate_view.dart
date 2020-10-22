library auto_rotate_view;

import 'dart:async';
import 'package:flutter/material.dart';

typedef AutoRotateBuilder<E> = Widget Function(BuildContext context, E item);
enum RotateDirection { UP, DOWN, LEFT, RIGHT, NONE }

class AutoRotateView<E> extends StatefulWidget {
  final List<E> items;
  final AutoRotateBuilder<E> builder;

  // default, RotateDirection.UP
  final RotateDirection direction;

  // default, true
  final bool infiniteRepeat;

  // default, Duration(seconds: 3)
  final Duration duration;

  // default, Duration(milliseconds: 800)
  final Duration animateDuration;

  // default, Duration(milliseconds: 0)
  final Duration delayedDuration;

  final ValueChanged<E> onChanged;

  final double transitionHeight;

  final CrossAxisAlignment crossAxisAlignment;

  AutoRotateView({
    @required this.items,
    @required this.builder,
    this.direction = RotateDirection.UP,
    this.infiniteRepeat = true,
    this.duration,
    this.animateDuration,
    this.delayedDuration,
    this.onChanged,
    this.transitionHeight,
    CrossAxisAlignment crossAxisAlignment,
  })  : assert(builder != null),
        this.crossAxisAlignment = crossAxisAlignment != null &&
                (direction != RotateDirection.LEFT &&
                    direction != RotateDirection.RIGHT)
            ? crossAxisAlignment
            : null;

  @override
  _AutoRotateViewState<E> createState() => _AutoRotateViewState<E>();
}

class _AutoRotateViewState<E> extends State<AutoRotateView<E>>
    with SingleTickerProviderStateMixin {
  AnimationController _animationIn;
  Animation _fadeIn, _fadeOut, _slideIn, _slideOut;

  int _index = -1;
  Timer _timer;
  int _duration;
  int _animateDuration;
  Duration _delayedDuration;
  double _transitionHeight;

  Alignment get _posIn {
    switch (widget.direction) {
      case RotateDirection.UP:
        return Alignment(-1.0, 1.0);
      case RotateDirection.DOWN:
        return Alignment(-1.0, -1.0);
      case RotateDirection.LEFT:
        return Alignment(2.0, 0.0);
      case RotateDirection.RIGHT:
        return Alignment(-2.0, 0.0);
      default:
        return Alignment(-1.0, 0.0);
    }
  }

  Alignment get _posOut {
    switch (widget.direction) {
      case RotateDirection.UP:
        return Alignment(-1.0, -1.0);
      case RotateDirection.DOWN:
        return Alignment(-1.0, 1.0);
      case RotateDirection.LEFT:
        return Alignment(-2.0, 0.0);
      case RotateDirection.RIGHT:
        return Alignment(2.0, 0.0);
      default:
        return Alignment(-1.0, 0.0);
    }
  }

  Alignment get _posOrigin {
    switch (widget.direction) {
      case RotateDirection.UP:
      case RotateDirection.DOWN:
        return Alignment(-1.0, 0.0);
      case RotateDirection.LEFT:
      case RotateDirection.RIGHT:
        return Alignment(-1.0, 0.0);
      default:
        return Alignment(-1.0, 0.0);
    }
  }

  double get _verticalPadding {
    switch (widget.direction) {
      case RotateDirection.UP:
      case RotateDirection.DOWN:
        return 4.0;
      default:
        return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _animateDuration = widget.animateDuration?.inMilliseconds ?? 800;
    _duration = widget.duration?.inMilliseconds ?? 3000;
    _duration += _animateDuration;
    _delayedDuration = widget.delayedDuration ?? Duration.zero;
    _initAnimation();
    _nextAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationIn?.stop();
    _animationIn?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (0 <= _index && _index < widget.items?.length ?? 0) {
      return LayoutBuilder(
        builder: (_, layout) {
          double height = layout.maxHeight;
          if (height == double.infinity) {
            height = _transitionHeight == null ? null : _transitionHeight;
          }
          return Container(
            width: layout.maxWidth,
            height: height,
            child: AnimatedBuilder(
              animation: _animationIn,
              child: Container(
                width:
                    widget.crossAxisAlignment != null ? layout.maxWidth : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      widget.crossAxisAlignment ?? CrossAxisAlignment.start,
                  children: [
                    widget.builder(context, widget.items[_index]),
                  ],
                ),
              ),
              builder: (ctx, child) {
                return AlignTransition(
                  alignment: _fadeIn.value != 1.0 ? _slideIn : _slideOut,
                  child: Opacity(
                    opacity:
                        _fadeIn.value != 1.0 ? _fadeIn.value : _fadeOut.value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _transitionHeight == null
                            ? _verticalPadding * 2
                            : 0,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return Container();
  }

  void _initAnimation() {
    _animationIn = AnimationController(
      duration: Duration(milliseconds: _duration),
      vsync: this,
    );

    _slideIn = AlignmentTween(
      begin: _posIn,
      end: _posOrigin,
    ).animate(
      CurvedAnimation(
        parent: _animationIn,
        curve: Interval(
          0.0,
          _animateDuration / 2 / _duration,
          curve: Curves.linear,
        ),
      ),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationIn,
        curve: Interval(
          0.0,
          _animateDuration / 2 / _duration,
          curve: Curves.easeOut,
        ),
      ),
    );

    _slideOut = AlignmentTween(
      begin: _posOrigin,
      end: _posOut,
    ).animate(
      CurvedAnimation(
        parent: _animationIn,
        curve: Interval(
          1 - _animateDuration / 2 / _duration,
          1.0,
          curve: Curves.linear,
        ),
      ),
    );

    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationIn,
        curve: Interval(
          1 - _animateDuration / 2 / _duration,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    )..addStatusListener(_animationEndCallback);
  }

  void _animationEndCallback(state) {
    if (state == AnimationStatus.completed) {
      assert(null == _timer || !_timer.isActive);
      _timer = Timer(_delayedDuration, _nextAnimation);
    }
  }

  void _nextAnimation() {
    if ((widget.items?.length ?? 0) - 1 <= _index) {
      _index = 0;
    } else {
      _index++;
    }

    // Handling onNext callback
    if (-1 < _index && _index < widget.items?.length ?? 0) {
      widget.onChanged?.call(widget.items[_index]);
    }
    try {
      _transitionHeight ??= widget.transitionHeight ?? context.size.height;
    } catch (_) {}
    if (mounted) {
      setState(() {});
    }
    _animationIn.forward(from: 0.0);
  }
}
