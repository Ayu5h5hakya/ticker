import 'package:flutter/material.dart';

class TickerText extends SingleChildRenderObjectWidget {
  const TickerText(this.value,
      {super.key, this.style, this.verticalOffset = 0.0});
  final String value;
  final TextStyle? style;
  final double verticalOffset;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    return RenderTicker(
        value, effectiveTextStyle!, verticalOffset, Directionality.of(context));
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderTicker renderObject) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(style);
    }
    renderObject.text = value;
    renderObject.direction = Directionality.of(context);
    renderObject.verticalOffset = verticalOffset;
    renderObject.style = effectiveTextStyle!;
  }
}

class RenderTicker extends RenderBox {
  RenderTicker(this._value, this._style, this._verticalOffset, this._direction)
      : _textPainter = TextPainter(
          text: TextSpan(text: _value, style: _style),
          textDirection: _direction,
        )..layout(),
        _nextPainter = TextPainter(textDirection: _direction);
  String _value = '';
  late double _verticalOffset;
  late TextDirection _direction;
  late TextStyle _style;
  final TextPainter _textPainter;
  final TextPainter _nextPainter;
  String _previousValue = '';

  set text(String value) {
    if (_value == value) return;
    _previousValue = _value;
    _value = value;
    _textPainter.text = textTextSpan;
    markNeedsLayout();
  }

  set direction(TextDirection direction) {
    if (_direction == direction) return;
    _direction = direction;
    markNeedsLayout();
  }

  set verticalOffset(double value) {
    if (_verticalOffset == value) return;
    _verticalOffset = value;
    markNeedsLayout();
  }

  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  TextSpan get textTextSpan => TextSpan(text: _value, style: _style);

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    final painter = TextPainter(
        text: TextSpan(text: _value, style: _style), textDirection: _direction);
    painter.layout();
    _textPainter.layout();
    size = constraints.constrain(painter.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawCircle(offset, 2, Paint()..color = Colors.black);
    if (_verticalOffset == 0.0) {
      _textPainter.paint(context.canvas, offset);
      return;
    }
    double offsetX = 0.0;
    for (int i = 0; i < _value.length; i++) {
      if (_value[i] == _previousValue[i]) {
        _textPainter.text = TextSpan(text: _value[i], style: _style);
        _layoutText(
            minWidth: constraints.minWidth, maxWidth: constraints.maxWidth);
        print('$i --> ${offset + Offset(offsetX, 0.0)}');
        _textPainter.paint(context.canvas, offset + Offset(offsetX, 0.0));
        offsetX += _textPainter.width;
      } else {
        _nextPainter.text = TextSpan(text: _value[i], style: _style);
        _nextPainter.layout();
        _nextPainter.paint(context.canvas,
            offset + Offset(offsetX, _verticalOffset * size.height * -1));
      }
    }
  }

  void _layoutText({double minWidth = 0.0, double maxWidth = double.infinity}) {
    _textPainter.layout(
      minWidth: minWidth,
      maxWidth: maxWidth,
    );
  }
}
