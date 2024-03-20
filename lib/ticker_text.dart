import 'package:flutter/material.dart';

class TickerText extends SingleChildRenderObjectWidget {
  const TickerText(
    this.data, {
    super.key,
    this.style,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 500),
    this.reverseDuration,
    required this.vsync,
  });
  final String data;
  final TextStyle? style;
  final Curve curve;
  final Duration duration;
  final Duration? reverseDuration;
  final TickerProvider vsync;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    return RenderTicker(
      data: data,
      direction: Directionality.of(context),
      style: effectiveTextStyle!,
      duration: duration,
      reverseDuration: reverseDuration,
      curve: curve,
      vsync: vsync,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderTicker renderObject) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    renderObject.text = data;
    renderObject.direction = Directionality.of(context);
    renderObject.style = effectiveTextStyle!;
  }
}

class RenderTicker extends RenderBox {
  RenderTicker({
    required this.data,
    required this.vsync,
    required TextStyle style,
    TextDirection direction = TextDirection.ltr,
    Duration? duration,
    Duration? reverseDuration,
    Curve curve = Curves.linear,
  })  : _style = style,
        _direction = direction,
        _textPainter = TextPainter(
          text: TextSpan(text: data, style: style),
          textDirection: direction,
        ),
        _nextPainter = TextPainter(textDirection: direction) {
    _textPainter.layout();
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
    )
      ..addListener(() {
        if (_controller.value != _lastValue) {
          markNeedsLayout();
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print(_lastValue);
          _lastValue = 0.0;
        }
      });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );
  }

  TickerProvider vsync;
  String data = '';

  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  double? _lastValue;

  TextDirection _direction;
  TextStyle _style;
  final TextPainter _textPainter;
  final TextPainter _nextPainter;
  String _previousValue = '';

  set text(String val) {
    if (data == val) return;
    _previousValue = data;
    data = val;
    _textPainter.text = textTextSpan;
    _controller.reset();
    _controller.forward();
  }

  set direction(TextDirection direction) {
    if (_direction == direction) return;
    _direction = direction;
    markNeedsLayout();
  }

  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  TextSpan get textTextSpan => TextSpan(text: data, style: _style);

  @override
  void performLayout() {
    _lastValue = _controller.value;
    final BoxConstraints constraints = this.constraints;
    _textPainter.layout();
    size = constraints.constrain(_textPainter.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_controller.isAnimating) {
      _textPainter.paint(context.canvas, offset);
      return;
    }
    context.canvas.save();
    context.canvas
        .clipRect(Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height));
    double offsetX = 0.0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == _previousValue[i]) {
        _nextPainter.text = TextSpan(text: data[i], style: _style);
        _nextPainter.layout();
        _nextPainter.paint(context.canvas, offset + Offset(offsetX, 0.0));
        offsetX += _nextPainter.width;
      } else {
        _nextPainter.text = TextSpan(text: _previousValue[i], style: _style);
        _nextPainter.layout();
        _nextPainter.paint(context.canvas,
            offset + Offset(offsetX, _controller.value * size.height * -1));
        _nextPainter.text = TextSpan(text: data[i], style: _style);
        _nextPainter.layout();
        _nextPainter.paint(
            context.canvas,
            offset +
                Offset(offsetX, (_controller.value - 1) * size.height * -1));
        offsetX += _nextPainter.width;
      }
    }
    context.canvas.restore();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animation.dispose();
    _textPainter.dispose();
    _nextPainter.dispose();
    super.dispose();
  }
}
