import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Gap extends LeafRenderObjectWidget {
  const Gap(
    this.mainAxisExtent, {
    Key? key,
  })  : assert(mainAxisExtent >= 0 && mainAxisExtent < double.infinity),
        super(key: key);
  final double mainAxisExtent;
  @override
  _RenderGap createRenderObject(BuildContext context) {
    return _RenderGap(mainAxisExtent: mainAxisExtent);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderGap renderObject) {
    renderObject.mainAxisExtent = mainAxisExtent;
  }
}

class _RenderGap extends RenderBox {
  _RenderGap({
    double? mainAxisExtent,
  }) : _mainAxisExtent = mainAxisExtent!;
  double get mainAxisExtent => _mainAxisExtent;
  double _mainAxisExtent;
  set mainAxisExtent(double value) {
    if (_mainAxisExtent != value) {
      _mainAxisExtent = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final flex = parent!;
    if (flex is RenderFlex) {
      if (flex.direction == Axis.horizontal) {
        size = constraints.constrain(Size(mainAxisExtent, 0));
      } else {
        size = constraints.constrain(Size(0, mainAxisExtent));
      }
    } else {
      throw FlutterError('Gap widget is not inside a flex parent');
    }
  }
}
