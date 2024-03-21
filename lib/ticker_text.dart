import 'package:flutter/material.dart';

class TickerText extends LeafRenderObjectWidget {
  const TickerText(
    this.data, {
    super.key,
    this.style,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 200),
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
    Curve curve = Curves.ease,
  })  : _style = style,
        _direction = direction,
        _textPainter = TextPainter(
          text: TextSpan(text: data, style: style),
          textDirection: direction,
        ) {
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
    )..addListener(() {
        if (_controller.value != _lastValue) {
          markNeedsLayout();
        }
      });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );
  }

  TextDirection _direction;
  TextStyle _style;
  TickerProvider vsync;
  String data = '';
  String _previousValue = '';

  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  double? _lastValue;

  final TextPainter _textPainter;

  bool _isOverFlowing = false;
  Matrix4? _transform;

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
    _isOverFlowing = false;
    final BoxConstraints constraints = this.constraints;

    _textPainter.layout();
    size = constraints.constrain(_textPainter.size);
    _isOverFlowing =
        _textPainter.width > size.width || _textPainter.height > size.height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_isOverFlowing) {
      final alignment = Alignment.center.resolve(_direction);
      final FittedSizes sizes =
          applyBoxFit(BoxFit.contain, _textPainter.size, size);
      final double scaleX = sizes.destination.width / sizes.source.width;
      final double scaleY = sizes.destination.height / sizes.source.height;
      final Rect destinationRect =
          alignment.inscribe(sizes.destination, Offset.zero & size);
      _transform = Matrix4.translationValues(
          destinationRect.left, destinationRect.top, 0.0)
        ..scale(scaleX, scaleY, 1.0);

      final Rect bounds = (offset + Offset(0, 50)) & Size(size.width, 200.0);
      context.canvas.save();
      context.canvas.clipRect(bounds);
      layer = context.pushTransform(
        needsCompositing,
        offset,
        _transform!,
        (context, offset) {
          _paintText(context, offset);
        },
      );
      context.canvas.restore();
    } else {
      final Rect bounds = (offset + Offset(0, 50)) & Size(size.width, 200.0);
      context.canvas.save();
      context.canvas.clipRect(bounds);
      _paintText(context, offset);
      context.canvas.restore();
    }
  }

  void _paintText(PaintingContext context, Offset offset) {
    if (!_controller.isAnimating) {
      _textPainter.paint(context.canvas, offset);
      return;
    }
    double offsetX = 0.0;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == _previousValue[i]) {
        offsetX +=
            _paintCharacter(context, offset + Offset(offsetX, 0.0), data[i]);
      } else {
        _paintCharacter(
            context,
            offset + Offset(offsetX, _controller.value * size.height * -1),
            _previousValue[i]);
        offsetX += _paintCharacter(
            context,
            offset +
                Offset(offsetX, (_controller.value - 1) * size.height * -1),
            data[i]);
      }
    }
  }

  double _paintCharacter(
    PaintingContext context,
    Offset offset,
    String character,
  ) {
    TextPainter charPainter = TextPainter(
        text: TextSpan(
          text: character,
          style: _style,
        ),
        textDirection: _direction);
    charPainter.layout();
    charPainter.paint(context.canvas, offset);
    return charPainter.width;
  }

  @override
  void dispose() {
    _controller.dispose();
    _animation.dispose();
    _textPainter.dispose();
    super.dispose();
  }
}
